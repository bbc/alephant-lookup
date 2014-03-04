require 'aws-sdk'
require 'alephant/lookup/lookup_query'
require 'alephant/logger'

module Alephant
  module Lookup
    class LocationWrite
      include ::Alephant::Logger

      attr_reader :table_name
      attr_reader :lookups

      def initialize(lookup_table)
        @table_name = lookup_table.table_name
        @batch = AWS::DynamoDB::BatchWrite.new
        @lookups = []
        @processed = false
      end

      def <<(lookup)
        raise TypeError unless lookup.is_a? LookupQuery

        @lookups << lookup
      end

      def processed?
        @processed
      end

      def process!
        logger.info("LocationWrite#process! #{processed? ? "not" : "is"} running batch put on #{table_name}")
        processed? ? false : process_batch_put
      end

      private

      def process_batch_put
        logger.info("LocationWrite#process_batch_put to #{table_name} for #{@lookups.map { |lookup| lookup.to_h }}")

        @batch.put(
          table_name,
          @lookups.map { |lookup| lookup.to_h }
        )
        @batch.process!

        processed = true
      end
    end
  end
end
