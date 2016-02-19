require 'dogaws/resource/base'

module Dogaws
  module Resource
    class << self
      def create(resource, from, to)
        require "dogaws/resource/#{resource['type']}"

        camelized = resource['type'].sub(/^[a-z\d]*/) { $&.capitalize }
        camelized.gsub!(/(?:_|(\/))([a-z\d]*)/i) { $2.capitalize }
        camelized.gsub!(/\//, '::')
        class_name = "Dogaws::Resource::#{camelized}"

        Object.const_get(class_name).new(resource, from, to)
      end
    end
  end
end
