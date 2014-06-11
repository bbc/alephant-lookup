require "alephant/lookup/lookup_table"
require "alephant/lookup/lookup_query"

require 'alephant/logger'

module Alephant
  module Lookup
    class LookupHelper
      include Logger

      attr_reader :lookup_table

      def initialize(lookup_table, logger)
        Logger.set_logger(logger)

        logger.info "LookupHelper#initialize(#{lookup_table.table_name})"

        @lookup_table = lookup_table
      end

      def read(id, opts, batch_version)
        logger.info "LookupHelper#read(#{id}, #{opts}, #{batch_version})"

        LookupQuery.new(lookup_table.table_name, id, opts, batch_version).run!
      end

      def write(id, opts, batch_version, location)
        logger.info "LookupHelper#write(#{id}, #{opts}, #{batch_version}, #{location})"

        LookupLocation.new(id, opts, batch_version, location).tap do |l|
          lookup_table.write(
            l.component_key,
            l.batch_version,
            l.location
          )
        end
      end

      def truncate!
        @lookup_table.truncate!
      end
    end
  end
end
