# Dogaws

Yet another [Datadog CloudWatch Integragion](http://docs.datadoghq.com/integrations/aws/).

## Usage

Run `dogaws` command like this:

```bash
$ dogaws --config dogaws.yml
I, [2016-02-19T16:22:15.774725 #29631]  INFO -- : aws.rds.cpuutilization ["region:ap-northeast-1", "availability-zone:ap-northeast-1b", "dbinstanceidentifier:db1", "dbinstanceclass:db.t2.micro", "engine:mysql", "engineversion:5.6.21b", "dbrole:master"] [["2016-02-19 07:17:00 UTC",7.42],["2016-02-19 07:15:00 UTC",12.08],["2016-02-19 07:13:00 UTC",10.75],["2016-02-19 07:14:00 UTC",16.33],["2016-02-19 07:16:00 UTC",10.92]]
...
```
This is an example of `dogaws.yml`:

```yaml
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

