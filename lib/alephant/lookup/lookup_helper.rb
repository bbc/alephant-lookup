require 'alephant/lookup/lookup_table'
require 'alephant/lookup/lookup_query'
require 'alephant/lookup/location_read'
require 'alephant/lookup/location_write'

module Alephant
  module Lookup
    class LookupHelper
      attr_reader :component_id

      def initialize(lookup_table, component_id = nil)
        @lookup_table = lookup_table
        @component_id = component_id
        create_lookup_table
      end

      def read(opts, ident = nil)
        ident = @component_id || ident
        reader = LocationRead.new(@lookup_table)
        reader.read(LookupQuery.new(ident, opts)).location
      end

      def write(opts, location, ident = nil)
        ident = @component_id || ident
        batch_write(opts, location, ident)
        batch_process
      end

      def batch_write(opts, location, ident = nil)
        ident = @component_id || ident
        @batch_write ||= LocationWrite.new(@lookup_table)
        @batch_write << LookupQuery.new(ident, opts, location)
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
