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
        'CurrConnections' => ['aws.elasticache.curr_connections', ['Maximum'], 'Count'],
        'CmdGet' => ['aws.elasticache.cmd_get', ['Sum'], 'Count'],
        'CmdSet' => ['aws.elasticache.cmd_set', ['Sum'], 'Count'],
        'GetHits' => ['aws.elasticache.get_hits', ['Sum'], 'Count'],
        'GetMisses' => ['aws.elasticache.get_misses', ['Sum'], 'Count'],
        'Evictions' => ['aws.elasticache.evictions', ['Sum'], 'Count'],
      }

      REDIS_CONFIG = {
        'CurrConnections' => ['aws.elasticache.curr_connections', ['Maximum'], 'Count'],
        'GetTypeCmds' => ['aws.elasticache.get_type_cmds', ['Sum'], 'Count'],
        'SetTypeCmds' => ['aws.elasticache.set_type_cmds', ['Sum'], 'Count'],
        'CacheHits' => ['aws.elasticache.cache_hits', ['Sum'], 'Count'],
        'CacheMisses' => ['aws.elasticache.cache_misses', ['Sum'], 'Count'],
        'Evictions' => ['aws.elasticache.evictions', ['Sum'], 'Count'],
        'ReplicationLag' => ['aws.elasticache.replication_lag', ['Maximum'], 'Seconds'],
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
            if n == 'ReplicationLag'
              next unless @options['replication']
            end

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
