module Dogaws
  module Resource
    class Base

      def initialize(resource, from, to)
        @name = resource['name']
        @type = resource['type']
        @tags = resource['tags']
        @dimensions = resource['dimensions'].map { |h| Hash[ h.map{ |k,v| [k.to_sym, v] } ] }
        @options = resource['options']

        @from = from
        @to = to
      end

      def metrics
        raise NotImplementedError
      end

      def culculated_metrics
        raise NotImplementedError
      end

    end
  end
end
