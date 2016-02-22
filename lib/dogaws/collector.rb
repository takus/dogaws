require 'json'
require 'parallel'
require 'aws-sdk'
require 'dogapi'

module Dogaws
  class Collector

    def initialize(config)
      @cloudwatch = Aws::CloudWatch::Client.new(region: config['aws']['region'])

      to = Time.now - config['aws']['delay_seconds']
      from = to - config['aws']['range_seconds']

      Dogaws::Resource.load(config['custom_resource_path'])
      @resources = config['aws']['resources'].map { |r| Dogaws::Resource.create(r, from, to) }

      @dog = Dogapi::Client.new(
        config['datadog']['api_key'],
        application_key=config['datadog']['app_key'],
        host=config['datadog']['host']
      )
      @concurrency = config['concurrency'] || 0
    end

    def run()
      Parallel.map(@resources, :in_threads => @concurrency) do |resource|
        begin
          @dog.batch_metrics {
            # points by name
            # {
            #   "aws.rds.read_iops": [
            #       ["1455895980", 2.516624722921285],
            #       ["1455896040", 3.516624722921285],
            #   ]
            # }
            point_by_name = {}

            # points by time
            # {
            #   "1455895980": {
            #     "aws.rds.read_iops":2.516624722921285,
            #     "aws.rds.write_iops":156.01406643222612,
            #   }
            # }
            point_by_time = {}

            resource.metrics.each do |m|
              point_by_name[m[:name]] = post(m)
              if point_by_name[m[:name]].size > 0
                Dogaws.logger.info "post #{point_by_name[m[:name]].size} metrics (#{m[:name]})"
              end
            end

            point_by_name.each do |name, points|
              points.each do |p|
                point_by_time[p[0]] ||= {}
                point_by_time[p[0]][name] = p[1]
              end
            end

            resource.calculated_metrics(point_by_time).each do |m|
              @dog.emit_points(
                m[:name],
                m[:points],
                :tags => m[:tags]
              )
              if m[:points].size > 0
                Dogaws.logger.info "post #{m[:points].size} metrics (#{m[:name]})"
              end
            end
          }
        rescue => e
          Dogaws.logger.error "#{e}"
        end
      end
    end

    def post(metric)
      begin
        points = @cloudwatch.get_metric_statistics(metric[:source]).datapoints.map { |d|
          [
            d.timestamp,
            d.maximum || d.sum || d.average || d.minimum || d.sample_count
          ]
        }
      rescue => e
        Dogaws.logger.error "#{e} - #{metric[:source].to_json}"
        return
      end

      Dogaws.logger.debug "#{metric[:name]} #{metric[:tags]} #{points.to_json}"
      @dog.emit_points(
        metric[:name],
        points,
        :tags => metric[:tags]
      )

      points
    end

  end
end
