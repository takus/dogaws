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

    end
  end
end
