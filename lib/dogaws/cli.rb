require 'thor'

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
        Dogaws::Config.configure(options)
        Dogaws::Collector.new.run
      rescue => e
        Dogaws.logger.error e
        exit 1
      end
    end
  end
end
