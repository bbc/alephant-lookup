require 'aws-sdk'
require 'alephant/lookup/lookup_query'

module Alephant
  module Lookup
    class LocationWrite
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
        processed? ? process_batch_put : false
      end

      private

      def process_batch_put
        @batch.put(
          table_name,
          @lookups.map { |lookup| lookup.to_h }
        ).process!

        processed = true
      end
    end
  end
end
