require "crimp"
require "alephant/lookup/lookup_location"
require "alephant/logger"

module Alephant
  module Lookup
    class LookupQuery
      include Logger
      attr_reader :table_name, :lookup_location

      def initialize(table_name, component_id, opts, batch_version)
        @client          = AWS::DynamoDB::Client::V20120810.new
        @table_name      = table_name
        @lookup_location = LookupLocation.new(component_id, opts, batch_version)

        logger.info(
          "event"        => "LookupQueryInitialized",
          "tableName"    => table_name,
          "componentId"  => component_id,
          "location"     => lookup_location,
          "batchVersion" => batch_version,
          "method"       => "#{self.class}#initialize"
        )
      end

      def run!
        lookup_location.tap do |l|
          l.location = s3_location_from(
            @client.query(to_q)
          ).tap do |loc|
            logger.info(
              "event"    => "S3LocationRetrieved",
              "location" => loc,
              "method"   => "#{self.class}#run!"
            )
          end
        end
      end

      private

      def s3_location_from(result)
        result[:count] == 1 ? result[:member].first["location"][:s] : nil
      end

      def to_q
        {
          :table_name        => table_name,
          :consistent_read   => true,
          :select            => "SPECIFIC_ATTRIBUTES",
          :attributes_to_get => ["location"],
          :key_conditions    => {
            "component_key" => {
              :comparison_operator  => "EQ",
              :attribute_value_list => [
                { "s" => @lookup_location.component_key }
              ]
            },
            "batch_version" => {
              :comparison_operator  => "EQ",
              :attribute_value_list => [
                { "n" => @lookup_location.batch_version.to_s }
              ]
            }
          }
        }
      end
    end
  end
end
