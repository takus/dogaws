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

      @dog = Dogapi::Client.new(
        config['datadog']['api_key'],
        application_key=config['datadog']['app_key'],
        host=config['datadog']['host']
      )

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
          @dog.batch_metrics {
            points = post(source)
            if points.size > 0
              Dogaws.logger.info "post #{points.size} metrics #{source['dimensions'].to_json}"
            end
          }
        rescue => e
          Dogaws.logger.error "failed to fetch #{source['dimensions'].to_json}"
          raise e
        end
      end
    end

    private

    def post(source)
      emitted_points = []

      available_metrics = @cloudwatch.list_metrics({
        namespace: @namespace,
        dimensions: source['dimensions'].map { |name, value| {name: name, value: value} }
      }).metrics

      available_metrics.each do |m|
        next unless @metric[m.metric_name]

        metric_alias = @metric[m.metric_name]['metric_alias']

        points = @cloudwatch.get_metric_statistics({
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

        tags = source['tags'] + m.dimensions.map { |d| "#{d.name.downcase}:#{d.value}" }

        emit(metric_alias, points, tags)

        emitted_points << {
          'metric_name' => m.metric_name,
          'dimensions' => m.dimensions.map { |d| {name: d.name, value: d.value} },
          'points' => points,
        }
      end

      emitted_points
    end

    def emit(name, points, tags)
      Dogaws.logger.info "#{name} #{points.to_json} #{tags}"
      @dog.emit_points(
        name,
        points,
        :tags => tags
      )
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
