require "crimp"
require "alephant/lookup/lookup_location"
require "alephant/logger"

module Alephant
  module Lookup
    class LookupQuery
      include Logger
      attr_reader :table_name, :lookup_location

      def initialize(table_name, component_id, opts, batch_version)
        options = {}
        options[:endpoint] = ENV['AWS_DYNAMO_DB_ENDPOINT'] if ENV['AWS_DYNAMO_DB_ENDPOINT']
        @client            = Aws::DynamoDB::Client.new(options)
        @table_name        = table_name
        @lookup_location   = LookupLocation.new(component_id, opts, batch_version)

        logger.info(
          event:        "LookupQueryInitialized",
          tableName:    table_name,
          componentId:  component_id,
          location:     lookup_location,
          batchVersion: batch_version,
          method:       "#{self.class}#initialize"
        )
      end

      def run!
        lookup_location.tap do |l|
          l.location = s3_location_from(
            @client.query(to_q)
          ).tap do |loc|
            logger.info(
              event:    "S3LocationRetrieved",
              location: loc,
              method:   "#{self.class}#run!"
            )
          end
        end
      end

      private

      def s3_location_from(result)
        result.count == 1 ? result.items.first['location'] : nil
      end

      def to_q
        {
          :table_name => table_name,
          :consistent_read => true,
          :projection_expression => '#loc',
          :expression_attribute_names => {
            '#loc' => 'location'
          },
          :key_condition_expression => 'component_key = :component_key AND batch_version = :batch_version',
          :expression_attribute_values => {
            ':component_key' => @lookup_location.component_key,
            ':batch_version' => @lookup_location.batch_version.to_i # @TODO: Verify if this is nil as this would be 0
          }
        }
      end
    end
  end
end
