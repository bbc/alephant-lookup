require "aws-sdk"
require "thread"
require "timeout"

require "alephant/support/dynamodb/table"
require "alephant/logger"

module Alephant
  module Lookup
    class LookupTable < ::Alephant::Support::DynamoDB::Table
      include Logger
      attr_reader :table_name, :client

      def initialize(table_name)
        @mutex      = Mutex.new
        @client     = AWS::DynamoDB::Client::V20120810.new
        @table_name = table_name
        logger.info(
          "event"     => "LookupTableInitialized",
          "tableName" => table_name,
          "method"    => "#{self.class}#initialize"
        )
      end

      def write(component_key, version, location)
        client.put_item(:table_name => table_name,
                        :item       => {
                          "component_key" => {
                            "S" => component_key.to_s
                          },
                          "batch_version" => {
                            "N" => version.to_s
                          },
                          "location"      => {
                            "S" => location.to_s
                          }
                        }).tap do
          logger.info(
            "event"        => "LookupLocationWritten",
            "componentKey" => component_key,
            "version"      => version,
            "location"     => location,
            "method"       => "#{self.class}#write"
          )
        end
      end
    end
  end
end
