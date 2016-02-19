module Dogaws
  module Resource
    class AwsElasticache < Base

      CONFIG = {
        'CPUUtilization' => ['aws.elasticache.cpuutilization', ['Maximum'], 'Percent'],
        'FreeableMemory' => ['aws.elasticache.freeable_memory', ['Minimum'], 'Bytes'],
        'SwapUsage' => ['aws.elasticache.swap_usage', ['Maximum'], 'Bytes'],
        'NetworkBytesIn' => ['aws.elasticache.network_bytes_in', ['Maximum'], 'Bytes'],
        'NetworkBytesOut'=> ['aws.elasticache.network_bytes_out', ['Maximum'], 'Bytes'],
      }

      MEMCACHED_CONFIG = {
        'Evictions' => ['aws.elasticache.evictions', ['Sum'], 'Count'],
      }

      REDIS_CONFIG = {
        'Evictions' => ['aws.elasticache.evictions', ['Sum'], 'Count'],
      }

      def metrics
        list = []

        CONFIG.each do |n, c|
          list << {
            name: c[0],
            tags: @tags,
            source: {
              namespace: 'AWS/ElastiCache',
              metric_name: n,
              dimensions: @dimensions,
              start_time: @from,
              end_time: @to,
              period: 60,
              statistics: c[1],
              unit: c[2]
            }
          }
        end

        if @options['engine'] == 'memcached'
          MEMCACHED_CONFIG.each do |n, c|
            list << {
              name: c[0],
              tags: @tags,
              source: {
                namespace: 'AWS/ElastiCache',
                metric_name: n,
                dimensions: @dimensions,
                start_time: @from,
                end_time: @to,
                period: 60,
                statistics: c[1],
                unit: c[2]
              }
            }
          end
        end

        if @options['engine'] == 'redis'
          REDIS_CONFIG.each do |n, c|
            list << {
              name: c[0],
              tags: @tags,
              source: {
                namespace: 'AWS/ElastiCache',
                metric_name: n,
                dimensions: @dimensions,
                start_time: @from,
                end_time: @to,
                period: 60,
                statistics: c[1],
                unit: c[2]
              }
            }
          end
        end

        list
      end

    end
  end
end
