require 'alephant/lookup/lookup_table'
require 'alephant/lookup/lookup_query'
require 'alephant/lookup/location_read'
require 'alephant/lookup/location_write'

module Alephant
  module Lookup
    class LookupHelper
      attr_reader :component_id

      def initialize(lookup_table, component_id)
        @lookup_table = lookup_table
        @component_id = component_id
        create_lookup_table
      end

      def read(opts)
        reader = LocationRead.new(@lookup_table)
        reader.read(LookupQuery.new(@component_id, opts)).location
      end

      def write(opts, location)
        writer = LocationWrite.new(@lookup_table)
        writer << LookupQuery.new(@component_id, opts, location)
        writer.process!
      end

      def batch_write(opts, location)
        @batch_write ||= LocationWrite.new(@lookup_table)
        @batch_write << LookupQuery.new(@component_id, opts, location)
      end

      def batch_process
        @batch_write.process!
        @batch_write = nil
      end

      private

      def create_lookup_table
        @lookup_table.create
      end

    end
  end
end
