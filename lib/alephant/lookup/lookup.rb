module Alephant
  module Lookup
    class Lookup
      attr_reader :component_id

      def initialize(lookup_table, component_id)
        @lookup_table = lookup_table
        @component_id = component_id
        create_lookup_table
      end

      def read(opts)
        @lookup_table.location_for(@component_id, opts)
      end

      def write(opts, location)
        fail
      end

      private

      def create_lookup_table
        @lookup_table.create
      end

    end
  end
end
