module Dogaws
  module Resource
    class AwsDynamodb < Base

      CONFIG = {
        'ConsumedReadCapacityUnits' => ['aws.dynamodb.consumed_read_capacity_units', ['Maximum'], 'Count'],
        'ConsumedWriteCapacityUnits' => ['aws.dynamodb.consumed_write_capacity_units', ['Maximum'], 'Count'],
        'ProvisionedReadCapacityUnits' => ['aws.dynamodb.provisioned_read_capacity_units', ['Maximum'], 'Count'],
        'ProvisionedWriteCapacityUnits' => ['aws.dynamodb.provisioned_write_capacity_units', ['Maximum'], 'Count'],
        'ReadThrottleEvents' => ['aws.dynamodb.read_throttle_events', ['Sum'], 'Count'],
        'WriteThrottleEvents' => ['aws.dynamodb.write_throttle_events', ['Sum'], 'Count'],
      }

      OPERATIONS = [
        'PutItem',
        'DeleteItem',
        'UpdateItem',
        'GetItem',
        'BatchGetItem',
        'Scan',
        'Query',
      ]

      def metrics
        list = []

        OPERATIONS.each do |op|
          list << {
            name: "aws.dynamodb.successful_request_latency",
            tags: @tags + ["Operation:#{op}"],
            source: {
              namespace: 'AWS/DynamoDB',
              metric_name: "SuccessfulRequestLatency",
              dimensions: @dimensions + [{name: "Operation", value: op}],
              start_time: @from,
              end_time: @to,
              period: 60,
              statistics: ['Maximum'],
              unit: 'Milliseconds'
            }
          }
        end

        CONFIG.keys.map do |metric_name|
          list << {
            name: CONFIG[metric_name][0],
            tags: @tags,
            source: {
              namespace: 'AWS/DynamoDB',
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
          if p['aws.dynamodb.consumed_read_capacity_units'] and p['aws.dynamodb.provisioned_read_capacity_units']
            points << {
              name: 'aws.rds.read_capacity_utilization',
              points: [
                [
                  Time.at(ts),
                  100 * p['aws.dynamodb.consumed_read_capacity_units'] / p['aws.dynamodb.provisioned_read_capacity_units']
                ]
              ],
              tags: @tags,
            }
          end
          if p['aws.dynamodb.consumed_write_capacity_units'] and p['aws.dynamodb.provisioned_write_capacity_units']
            points << {
              name: 'aws.rds.write_capacity_utilization',
              points: [
                [
                  Time.at(ts),
                  100 * p['aws.dynamodb.consumed_write_capacity_units'] / p['aws.dynamodb.provisioned_write_capacity_units']
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
