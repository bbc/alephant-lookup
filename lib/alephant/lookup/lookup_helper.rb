require 'alephant/lookup/lookup_table'
require 'alephant/lookup/lookup_query'
require 'alephant/lookup/location_read'
require 'alephant/lookup/location_write'

module Alephant
  module Lookup
    class LookupHelper

      def initialize(lookup_table)
        @lookup_table = lookup_table
        @lookup_table.create
      end

      def read(id, opts, batch_version)
        LookupQuery.new(@lookup_table.table_name, id, opts, batch_version).run!
      end

      def write(id, opts, batch_version, location)
        LookupLocation.new(id, batch_version, opts, location).tap do |l|
          @lookup_table.table.batch_put([
            {
              :component_key => l.component_key,
              :batch_version => l.batch_version,
              :location      => l.location
            }
          ])
        end
      end

    end
  end
end
