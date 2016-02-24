require 'yaml'
require 'hashie/mash'

module Dogaws
  class Config
    class << self
      attr_reader :opts

      def configure(opts)
        @opts = opts
      end

      def config_path
        @config_path ||= opts[:config] || 'dogaws.yml'
      end

      def config
        @config ||= Hashie::Mash.new(YAML.load_file(config_path))
      end

    end
  end
end
