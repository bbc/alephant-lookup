require 'aws-sdk'
require 'alephant/lookup/lookup_location'
require 'alephant/lookup/lookup_query'
require 'alephant/logger'

module Alephant
  module Lookup
    class LocationRead
      include ::Alephant::Logger

      attr_reader :table_name

      def initialize(lookup_table)
        @client = AWS::DynamoDB::Client::V20120810.new
        @table_name = lookup_table.table_name
      end

      def read(lookup)
        logger.info("LocationRead#read: looking up #{lookup.to_h}")
        raise TypeError unless lookup.is_a? LookupQuery

        location = LookupLocation.new(
          lookup.component_id,
          lookup.opts_hash,
          s3_location_from(
            run_query(
              lookup.component_id,
              lookup.opts_hash
            )
          )
        )
        logger.info("LocationRead#read: got location #{location.to_h}")

        location
      end

      private

      def s3_location_from(result)
        result[:count] == 1 ? result[:member].first[LookupLocation::S3_LOCATION_FIELD][:s] : nil
      end

      def run_query(component_id, opts_hash)
        @client.query(query(component_id, opts_hash))
      end

      def query(component_id, opts_hash)
        {
          :table_name => table_name,
          :consistent_read => true,
          :select => 'SPECIFIC_ATTRIBUTES',
          :attributes_to_get => [LookupLocation::S3_LOCATION_FIELD],
          :key_conditions => {
            'component_id' => {
              :comparison_operator => 'EQ',
              :attribute_value_list => [
                { 's' => component_id.to_s }
              ],
            },
            'opts_hash' => {
              :comparison_operator => 'EQ',
              :attribute_value_list => [
                { 's' => opts_hash }
              ]
            }
          }
        }
      end
    end
  end
end
