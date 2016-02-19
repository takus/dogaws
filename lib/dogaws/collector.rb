require 'logger'
require 'json'
require 'parallel'
require 'aws-sdk'
require 'dogapi'

module Dogaws
  class Collector

    def initialize(config)
      @logger = Logger.new(STDERR).tap { |logger|
        logger.level = Logger::INFO
      }

      @cloudwatch = Aws::CloudWatch::Client.new(region: config['aws']['region'])

      to = Time.now - config['aws']['delay_seconds']
      from = to - config['aws']['range_seconds']
      @resources = config['aws']['resources'].map { |r| Dogaws::Resource::create(r, from, to) }

      @dog = Dogapi::Client.new(
        config['datadog']['api_key'],
        application_key: config['datadog']['app_key'],
        host: config['datadog']['host']
      )
      @concurrency = config['concurrency'] || 0
    end

    def run()
      Parallel.map(@resources, :in_threads => @concurrency) do |resource|
        begin
          @dog.batch_metrics {
            resource.metrics.each do |m|
              post(m)
            end
          }
        rescue => e
          @logger.error "#{e}"
        end
      end
    end

    def post(metric)
      begin
        points = @cloudwatch.get_metric_statistics(metric[:source]).datapoints.map { |d| [d.timestamp, d.maximum] }
        @logger.info "#{metric[:name]} #{metric[:tags]} #{points.to_json}"
        @dog.emit_points(
          metric[:name],
          points,
          :tags => metric[:tags]
        )
      rescue => e
        @logger.error "#{e} - #{metric[:source].to_json}"
      end
    end

  end
end
