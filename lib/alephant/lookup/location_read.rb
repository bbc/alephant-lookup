require 'aws-sdk'

module Alephant
  module Lookup
    class LocationRead
      S3_LOCATION_FIELD = 's3_location'

      attr_reader :location, :table_name

      def initialize(lookup_table)
        @client = AWS::DynamoDB::Client::V20120810.new
        @table_name = lookup_table.table_name
      end

      def read(lookup)
        raise TypeError unless lookup.is_a? LookupQuery

        LookupLocation.new(
          lookup.component_id,
          lookup.opts_hash,
          s3_location_from(
            query(
              lookup.component_id,
              lookup.opts_hash
            )
          )
        )
      end

      private

      def s3_location_from(result)
        result[:count] == 1 ? result[:member].first[S3_LOCATION_FIELD][:s] : nil
      end

      def query(component_id, opts_hash)
        @client.query({
          :table_name => @table_name,
          :consistent_read => true,
          :select => 'SPECIFIC_ATTRIBUTES',
          :attributes_to_get => [S3_LOCATION_FIELD],
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
        })
      end
    end
  end
end
