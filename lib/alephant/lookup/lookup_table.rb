require "aws-sdk"
require "thread"
require "timeout"

require "alephant/support/dynamodb/table"

module Alephant
  module Lookup
    class LookupTable < ::Alephant::Support::DynamoDB::Table
      attr_reader :table_name

      SCHEMA = {
        :hash_key => {
          :component_key => :string
        },
        :range_key => {
          :batch_version => :number
        }
      }

      def initialize(table_name, config = DEFAULT_CONFIG)
        @mutex      = Mutex.new
        @dynamo_db  = AWS::DynamoDB.new
        @table_name = table_name
        @config     = config
      end

      def create
        @mutex.synchronize do
          ensure_table_exists
          ensure_table_active
        end
      end

      def table
        @table ||= @dynamo_db.tables[@table_name]
      end

      private

      def ensure_table_exists
        create_dynamodb_table unless table.exists?
      end

      def ensure_table_active
        sleep_until_table_active unless table_active?
      end

      def create_dynamodb_table
        @table = @dynamo_db.tables.create(
          @table_name,
          @config[:read_units],
          @config[:write_units],
          SCHEMA
        )
      end

      def table_active?
        table.status == :active
      end

      def sleep_until_table_active
        begin
          Timeout::timeout(TIMEOUT) do
            sleep 1 until table_active?
          end
        end
      end
    end
  end
end
