require 'thor'
require 'yaml'

module Dogaws
  class CLI < Thor
    default_command :post

    desc "post", "post cloudwatch metrics to datadog"
    class_option :config,
      :aliases => ["c"],
      :default => "dogaws.yml",
      :type    => :string
    def post
      begin
        config = YAML.load_file(options[:config])
        Dogaws::Collector.new(config).run
      rescue => e
        Dogaws.logger.error e.message
        exit 1
      end
    end
  end
end
