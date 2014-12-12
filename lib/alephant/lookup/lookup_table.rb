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
        logger.info "LookupTable#initialize: table name '#{table_name}'"
      end

      def write(component_key, version, location)
        logger.info "LookupTable#write: component key '#{component_key}', version '#{version}', location '#{location}'"

        client.put_item({
          :table_name => table_name,
          :item => {
            'component_key' => {
              'S' => component_key.to_s
            },
            'batch_version' => {
              'N' => version.to_s
            },
            'location' => {
              'S' => location.to_s
            }
          }
        })
      end

    end
  end
end
