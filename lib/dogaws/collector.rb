require 'json'
require 'parallel'
require 'aws-sdk'
require 'dogapi'

module Dogaws
  class Collector

    def initialize()
      config = Dogaws::Config.config

      aws_option = {
        region: config['aws']['region']
      }
      if config['aws']['access_key'] and config['aws']['secret_key']
        aws_option[:access_key_id] = config['aws']['access_key']
        aws_option[:secret_access_key] = config['aws']['secret_key']
      end
      @cloudwatch = Aws::CloudWatch::Client.new(aws_option)

      @namespace = config['namespace'] or raise "'namespace' is missing"
      @metric = config['metric'] or raise "'metric' is missing"
      set_alias
      @sources = config['sources'] or raise "'sources' is missing"

      option = config['option'] || {}
      @end_time = Time.now - (option['delay_seconds'] || 60)
      @start_time = @end_time - (option['range_seconds'] || 600)
      @period = option['period'] || 60
      @concurrency = option['concurrency'] || 0
    end

    def run
      Parallel.map(@sources, :in_threads => @concurrency) do |source|
        begin
          emitted = 0

          metric_statistics = fetch(source)

          dog = Dogapi::Client.new(
            Dogaws::Config.config['datadog']['api_key'],
            application_key=Dogaws::Config.config['datadog']['app_key'],
            host=Dogaws::Config.config['datadog']['host']
          )
          dog.batch_metrics {
            metric_statistics.each do |s|
              name = @metric[s['metric_name']]['metric_alias']
              points = s['datapoints']
              tags = source['tags'] + s['dimensions'].map { |d| "#{d['name'].downcase}:#{d['value']}" }
              dog.emit_points(
                name,
                points,
                :tags => tags
              )
              emitted = emitted + points.size
            end
          }
          Dogaws.logger.info "post #{emitted} points in #{source['dimensions'].to_json}"
        rescue => e
          Dogaws.logger.error "failed to fetch #{source['dimensions'].to_json}"
          raise e
        end
      end
    end

    private

    def fetch(source)
      metric_statistics = []

      available_metrics = @cloudwatch.list_metrics({
        namespace: @namespace,
        dimensions: source['dimensions'].map { |name, value| {name: name, value: value} }
      }).metrics

      available_metrics.each do |m|
        next unless @metric[m.metric_name]

        datapoints = @cloudwatch.get_metric_statistics({
          namespace: m.namespace,
          metric_name: m.metric_name,
          dimensions: m.dimensions.map { |d| {name: d.name, value: d.value} },
          start_time: @start_time,
          end_time: @end_time,
          period: @period,
          statistics: [@metric[m.metric_name]['statistics']],
          unit: @metric[m.metric_name]['unit'],
        }).datapoints.map { |d|
          [
            d.timestamp,
            d.maximum || d.sum || d.average || d.minimum || d.sample_count
          ]
        }

        metric_statistics << {
          'metric_name' => m.metric_name,
          'dimensions' => m.dimensions.map { |d| {'name' => d.name, 'value' => d.value} },
          'datapoints' => datapoints,
        }
      end

      metric_statistics
    end

    def set_alias
      @metric.keys.each do |metric_name|
        unless @metric[metric_name]['metric_alias']
          prefix = @namespace.downcase.gsub(/\//, '.')
          suffix = metric_name.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").downcase
          @metric[metric_name]['metric_alias'] = "#{prefix}.#{suffix}"
        end
      end
    end

  end
end
