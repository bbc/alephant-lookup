require 'aws-sdk'
require 'thread'
require 'timeout'
require 'crimp'

module Alephant
  module Lookup
    class LookupTable
      attr_reader :table_name

      TIMEOUT = 120
      DEFAULT_CONFIG = {
        :write_units => 5,
        :read_units  => 10
      }
      SCHEMA = {
        :hash_key => {
          :id => :string
        },
        :range_key => {
          :location => :string
        }
      }

      S3_LOCATION_FIELD = 's3_location'

      def initialize(table_name, config = DEFAULT_CONFIG)
        @mutex      = Mutex.new
        @dynamo_db  = AWS::DynamoDB.new
        @client     = AWS::DynamoDB::Client::V20120810.new
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


      def location_for(component_id, opts)
        result = @client.query({
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
                { 's' => hash_for(opts) }
              ]
            }
          }
        })
        result[:count] == 1 ? result[:member].first[S3_LOCATION_FIELD][:s] : nil
      end

      def write_location_for(component_id, opts, location)

        @table.batch_put([
          {
            :component_id => component_id,
            :opts_hash    => hash_for(opts),
            :s3_location  => location
          }
        ])
      end

      private

      def hash_for(opts)
        Crimp.signature opts
      end

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
