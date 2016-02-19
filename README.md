# Dogaws

Yet another [Datadog CloudWatch Integragion](http://docs.datadoghq.com/integrations/aws/). Dogaws gets CloudWatch metrics for AWS services such as RDS, DynamoDB, ElastiCache, and posts them to Datadog.

## Usage

Run `dogaws` command like this:

```bash
# post cloudwatch metrics to datadog
$ dogaws --config dogaws.yml
I, [2016-02-20T01:28:19.119674 #30543]  INFO -- : register (Dogaws::Resource::AwsElasticache)
I, [2016-02-20T01:28:19.120304 #30543]  INFO -- : register (Dogaws::Resource::AwsRds)
I, [2016-02-20T01:28:19.120350 #30543]  INFO -- : register (Dogaws::Resource::Base)
I, [2016-02-20T01:28:19.640037 #30543]  INFO -- : post 5 metrics (aws.rds.read_iops)
I, [2016-02-20T01:28:19.673308 #30543]  INFO -- : post 5 metrics (aws.rds.write_iops)
I, [2016-02-20T01:28:19.708111 #30543]  INFO -- : post 5 metrics (aws.rds.read_latency)
I, [2016-02-20T01:28:19.737766 #30543]  INFO -- : post 5 metrics (aws.rds.write_latency)
I, [2016-02-20T01:28:19.762912 #30543]  INFO -- : post 4 metrics (aws.rds.cpuutilization)
I, [2016-02-20T01:28:19.796351 #30543]  INFO -- : post 5 metrics (aws.rds.freeable_memory)
I, [2016-02-20T01:28:19.825345 #30543]  INFO -- : post 5 metrics (aws.rds.free_storage_space)
I, [2016-02-20T01:28:19.846445 #30543]  INFO -- : post 5 metrics (aws.rds.network_receive_throughput)
I, [2016-02-20T01:28:19.870566 #30543]  INFO -- : post 5 metrics (aws.rds.network_transmit_throughput)
I, [2016-02-20T01:28:19.870674 #30543]  INFO -- : post 1 metrics (aws.rds.iops_utilization)
I, [2016-02-20T01:28:19.870713 #30543]  INFO -- : post 1 metrics (aws.rds.iops_utilization)
I, [2016-02-20T01:28:19.870731 #30543]  INFO -- : post 1 metrics (aws.rds.iops_utilization)
I, [2016-02-20T01:28:19.870751 #30543]  INFO -- : post 1 metrics (aws.rds.iops_utilization)
I, [2016-02-20T01:28:19.870767 #30543]  INFO -- : post 1 metrics (aws.rds.iops_utilization)
```
This is an example of `dogaws.yml`:

```yaml
custom_resource_path: /path/to/custom_resource
aws:
  region: ap-northeast-1
  resources:
    - name: db1
      type: aws_rds
      dimensions:
        - name: DBInstanceIdentifier
          value: db1
      tags:
        - region:ap-northeast-1
        - availability-zone:ap-northeast-1b
        - dbinstanceidentifier:db1
        - dbinstanceclass:db.t2.micro
        - engine:mysql
        - engineversion:5.6.21b
        - dbrole:master
datadog:
  host: cloudwatch
  api_key: xxxx
  app_key: xxxx
```

You can execute dogaws at regular interval with cron:

```
* * * * * dogaws -c amazon_rds.yml
* * * * * dogaws -c amazon_elasticache.yml
* * * * * dogaws -c amazon_cloudsearch.yml
* * * * * dogaws -c amazon_dynamodb.yml
* * * * * dogaws -c amazon_kinesis.yml
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dogaws'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dogaws

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/takus/dogaws. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

