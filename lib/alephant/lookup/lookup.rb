module Alephant
  module Lookup
    class Lookup
      attr_reader :component_id

      def initialize(lookup_table, component_id)
        @lookup_table = lookup_table
        @component_id = component_id

        @lookup_table.create
      end

      def read(opts)
        fail
      end

      def write(opts, location)
        fail
      end

    end
  end
end
