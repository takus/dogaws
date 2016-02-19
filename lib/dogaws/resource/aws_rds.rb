module Dogaws
  module Resource
    class AwsRds < Base

      CONFIG = {
        'ReadIOPS' => ['aws.rds.read_iops', ['Maximum'], 'Count/Second'],
        'WriteIOPS' => ['aws.rds.write_iops', ['Maximum'], 'Count/Second'],
        'ReadLatency' => ['aws.rds.read_latency', ['Maximum'], 'Seconds'],
        'WriteLatency' => ['aws.rds.write_latency', ['Maximum'], 'Seconds'],
        'CPUUtilization' => ['aws.rds.cpuutilization', ['Maximum'], 'Percent'],
        'FreeableMemory' => ['aws.rds.freeable_memory', ['Minimum'], 'Bytes'],
        'FreeStorageSpace'=> ['aws.rds.free_storage_space', ['Minimum'], 'Bytes'],
        'NetworkReceiveThroughput' => ['aws.rds.network_receive_throughput', ['Maximum'], 'Bytes/Second'],
        'NetworkTransmitThroughput'=> ['aws.rds.network_transmit_throughput', ['Maximum'], 'Bytes/Second'],
      }

      def metrics
        CONFIG.keys.map { |metric_name|
          {
            name: CONFIG[metric_name][0],
            tags: @tags,
            source: {
              namespace: 'AWS/RDS',
              metric_name: metric_name,
              dimensions: @dimensions,
              start_time: @from,
              end_time: @to,
              period: 60,
              statistics: CONFIG[metric_name][1],
              unit: CONFIG[metric_name][2]
            }
          }
        }
      end

      def calculated_metrics(point_by_time)
        iops =
          if @options['storage_type'] == 'io1'
            @options['iops']
          elsif @options['storage_type'] == 'gp2' and @options['allocated_storage']
            @options['allocated_storage'] * 3
          elsif @options['storage_type'] == 'standard'
            100
          else
            nil
          end

        points = []
        point_by_time.each do |ts, p|
          if iops and p['aws.rds.read_iops'] and p['aws.rds.write_iops']
            points << {
              name: 'aws.rds.iops_utilization',
              points: [
                [Time.at(ts), 100 * (p['aws.rds.read_iops'] + p['aws.rds.write_iops']) / iops ]
              ],
              tags: @tags,
            }
          end
        end
        points
      end

    end
  end
end
