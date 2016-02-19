module Dogaws
  module Resource
    class Base

      def initialize(resource, from, to)
        @name = resource['name']
        @type = resource['type']
        @tags = resource['tags']
        @dimensions = resource['dimensions'].map { |h| Hash[ h.map{ |k,v| [k.to_sym, v] } ] }

        @from = from
        @to = to
      end

    end
  end
end