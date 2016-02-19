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
      config = YAML.load_file(options[:config])
      Dogaws::Collector.new(config).run
    end
  end
end
