# Dogaws

Yet another [Datadog CloudWatch Integragion](http://docs.datadoghq.com/integrations/aws/). Dogaws gets CloudWatch metrics for AWS services such as RDS, DynamoDB, ElastiCache, and posts them to Datadog.

## Usage

Run `dogaws` command like this:

```bash
# post cloudwatch metrics to datadog
$ dogaws --config dogaws.yml
I, [2016-02-24T15:46:15.654575 #67420]  INFO -- : post 2 metrics {"DBInstanceIdentifier":"xxxx"}
```
This is an example of `dogaws.yml` (See `examples` in detail):

```yaml
namespace: AWS/RDS
metric:
  ReadIOPS:
    statistics: Maximum
    unit: Count/Second
  WriteIOPS:
    statistics: Maximum
    unit: Count/Second
sources:
  - dimensions:
      DBInstanceIdentifier: YOUR_DB_INSTANCE
    tags:
      - region:ap-northeast-1
      - availability-zone:ap-northeast-1b
      - dbinstanceclass:db.r3.xlarge
      - engine:mysql
      - engineversion:5.6.21b
aws:
  access_key: AWS_ACCESS_KEY_ID
  secret_key: AWS_SECRET_ACCESS_KEY
  region: AWS_REGION
datadog:
  host: cloudwatch
  api_key: DD_API_KEY
  app_key: DD_APP_KEY
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

