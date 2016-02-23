module Dogaws
  module Resource
    class AwsKinesis < Base

      CONFIG = {
        'IncomingBytes' => ['aws.kinesis.incoming_bytes', ['Sum'], 'Bytes'],
        'IncomingRecords' => ['aws.kinesis.incoming_records', ['Sum'], 'Count'],
        'GetRecords.Bytes' => ['aws.kinesis.get_records_bytes', ['Sum'], 'Bytes'],
        'PutRecord.Latency' => ['aws.kinesis.put_record_latency', ['Maximum'], 'Milliseconds'],
        'PutRecords.Latency' => ['aws.kinesis.put_records_latency', ['Maximum'], 'Milliseconds'],
        'GetRecords.Latency'  => ['aws.kinesis.get_records_latency', ['Maximum'], 'Milliseconds'],
        'GetRecords.IteratorAgeMilliseconds' => ['aws.kinesis.iterator_age_milliseconds', ['Maximum'], 'Milliseconds'],
      }

      def metrics
        list = []

        CONFIG.keys.map do |metric_name|
          list << {
            name: CONFIG[metric_name][0],
            tags: @tags,
            source: {
              namespace: 'AWS/Kinesis',
              metric_name: metric_name,
              dimensions: @dimensions,
              start_time: @from,
              end_time: @to,
              period: 60,
              statistics: CONFIG[metric_name][1],
              unit: CONFIG[metric_name][2]
            }
          }
        end

        list
      end

      def calculated_metrics(point_by_time)
        points = []
        point_by_time.each do |ts, p|
          if @options['shards'] and p['aws.kinesis.incoming_bytes']
            points << {
              name: 'aws.kinesis.put_bytes_utilization',
              points: [
                [
                  Time.at(ts),
                  100 * p['aws.kinesis.incoming_bytes'] / (@options['shards'] * 1024 * 1024 * 60)
                ]
              ],
              tags: @tags,
            }
          end
          if @options['shards'] and p['aws.kinesis.incoming_records']
            points << {
              name: 'aws.kinesis.put_records_utilization',
              points: [
                [
                  Time.at(ts),
                  100 * p['aws.kinesis.incoming_records'] / (@options['shards'] * 1000 * 60)
                ]
              ],
              tags: @tags,
            }
          end
          if @options['shards'] and p['aws.kinesis.get_records_bytes']
            points << {
              name: 'aws.kinesis.get_bytes_utilization',
              points: [
                [
                  Time.at(ts),
                  100 * p['aws.kinesis.get_records_bytes'] / (@options['shards'] * 2 * 1024 * 1024 * 60)
                ]
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
