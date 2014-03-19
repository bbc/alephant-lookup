require 'crimp'
require 'alephant/lookup/lookup_location'

module Alephant
  module Lookup
    class LookupQuery
      attr_reader :table_name, :lookup_location

      def initialize(table_name, component_id, opts, batch_version)
        @client = AWS::DynamoDB::Client::V20120810.new
        @table_name = table_name
        @lookup_location = LookupLocation.new(component_id, opts, batch_version)
      end

      def run!
        lookup_location.tap do |l|
          l.location = s3_location_from(
            @client.query(to_q)
          )
        end
      end

      private

      def s3_location_from(result)
        result[:count] == 1 ? result[:member].first['location'][:s] : nil
      end

      def to_q
        {
          :table_name => table_name,
          :consistent_read => true,
          :select => 'SPECIFIC_ATTRIBUTES',
          :attributes_to_get => ['location'],
          :key_conditions => {
            'component_key' => {
              :comparison_operator => 'EQ',
              :attribute_value_list => [
                { 's' => @lookup_location.component_key }
              ],
            },
            'batch_version' => {
              :comparison_operator => 'EQ',
              :attribute_value_list => [
                { 'n' => @lookup_location.batch_version.to_s }
              ]
            }
          }
        }
      end
    end
  end
end
