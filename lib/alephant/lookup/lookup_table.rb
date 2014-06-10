require "aws-sdk"
require "thread"
require "timeout"

require "alephant/support/dynamodb/table"

module Alephant
  module Lookup
    class LookupTable < ::Alephant::Support::DynamoDB::Table
      attr_reader :table_name, :client

      def initialize(table_name)
        @mutex      = Mutex.new
        @client     = AWS::DynamoDB::Client::V20120810.new
        @table_name = table_name
      end

      def write(component_key, version, location)
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
