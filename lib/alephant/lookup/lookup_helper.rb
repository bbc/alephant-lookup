require "alephant/lookup/lookup_table"
require "alephant/lookup/lookup_query"

require "alephant/logger"

module Alephant
  module Lookup
    class LookupHelper
      include Logger

      attr_reader :lookup_table

      def initialize(lookup_table)
        @lookup_table = lookup_table

        logger.info(
          "event"     => "LookupHelperInitialized",
          "tableName" => lookup_table.table_name,
          "method"    => "#{self.class}#initialize"
        )
      end

      def read(id, opts, batch_version)
        LookupQuery.new(lookup_table.table_name, id, opts, batch_version).run!.tap do
          logger.info(
            "event"        => "LookupQuery",
            "tableName"    => lookup_table.table_name,
            "id"           => id,
            "opts"         => opts,
            "batchVersion" => batch_version,
            "method"       => "#{self.class}#read"
          )
        end
      end

      def write(id, opts, batch_version, location)
        LookupLocation.new(id, opts, batch_version, location).tap do |l|
          lookup_table.write(
            l.component_key,
            l.batch_version,
            l.location
          ).tap do
            logger.info(
              "event"        => "LookupLocationUpdated",
              "location"     => location,
              "id"           => id,
              "opts"         => opts,
              "batchVersion" => batch_version,
              "method"       => "#{self.class}#write"
            )
          end
        end
      end

      def truncate!
        @lookup_table.truncate!
      end
    end
  end
end
