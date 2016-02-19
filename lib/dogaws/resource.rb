require 'dogaws/resource/base'

module Dogaws
  module Resource
    @class_name = {}

    class << self
      def load(path)
        paths = [ File.join(File.expand_path('../resource', __FILE__), "*.rb") ]
        if path
          paths.unshift File.join(path, "*.rb")
        end

        paths.each do |path|
          Dir.glob(path).each do |file|
            require file

            type = File.basename(file, ".rb")
            camelized = type.sub(/^[a-z\d]*/) { $&.capitalize }
            camelized.gsub!(/(?:_|(\/))([a-z\d]*)/i) { $2.capitalize }
            camelized.gsub!(/\//, '::')

            @class_name[type] = "Dogaws::Resource::#{camelized}"
            Dogaws.logger.info "register (Dogaws::Resource::#{camelized}) "
          end
        end
      end

      def create(resource, from, to)
        Object.const_get(@class_name[resource['type']]).new(resource, from, to)
      end
    end

  end
end
