require "spec_helper"

describe Alephant::Lookup do
  describe ".create" do
    it "returns a lookup" do
      expect_any_instance_of(Alephant::Lookup::LookupHelper).to receive(:initialize)

      expect(subject.create(:table_name)).to be_a Alephant::Lookup::LookupHelper
    end
  end

  describe Alephant::Lookup::LookupHelper do
    subject { Alephant::Lookup::LookupHelper }

    describe "#initialize" do
      it "calls create on lookup_table" do
        table = double()
        expect(table).to receive(:table_name)
        subject.new(table)
      end
    end

    describe "#read" do
      let(:expected_query) do
        {
          :table_name=>"table_name",
          :consistent_read=>true,
          :select=>"SPECIFIC_ATTRIBUTES",
          :attributes_to_get=>["location"],
          :key_conditions=>{
            "component_key"=> {
              :comparison_operator=>"EQ",
              :attribute_value_list=>[{"s"=>"id/218c835cec343537589dbf1619532e4d"}]
            },
            "batch_version"=>{
              :comparison_operator=>"EQ",
              :attribute_value_list=>[{"n"=>"0"}]
            }
          }
        }
      end

      it "queries DynamoDb and returns a location when not in cache" do
        expect_any_instance_of(Dalli::ElastiCache).to receive(:initialize)
        expect_any_instance_of(Dalli::ElastiCache).to receive(:client).and_return(Dalli::Client.new)

        expect_any_instance_of(Dalli::Client).to receive(:get)
        expect_any_instance_of(Dalli::Client).to receive(:set)

        expect_any_instance_of(AWS::DynamoDB::Client::V20120810)
          .to receive(:initialize)

        expect_any_instance_of(AWS::DynamoDB::Client::V20120810)
          .to receive(:query)
          .with(expected_query)
          .and_return(
            {
              :count => 1,
              :member => [
                { "location" => { :s => "/location" } }
              ]
            }
          )

        table = double().as_null_object
        expect(table).to receive(:table_name).and_return("table_name").exactly(4).times

        config = { "elasticache_config_endpoint" => "/cache" }

        instance = subject.new(table, config)
        lookup = instance.read("id", {:variant => "foo"}, 0)

        expect(lookup.location).to eq("/location")
      end

      it "reads location from the cache when in cache" do
        lookup_location = Alephant::Lookup::LookupLocation.new("id", {:variant => "foo"}, 0, "/location")

        expect_any_instance_of(Dalli::ElastiCache).to receive(:initialize)
        expect_any_instance_of(Dalli::ElastiCache).to receive(:client).and_return(Dalli::Client.new)

        expect_any_instance_of(Dalli::Client).to receive(:get)
          .with("table_name/id/218c835cec343537589dbf1619532e4d/0")
          .and_return(lookup_location)
        expect_any_instance_of(Dalli::Client).to_not receive(:set)

        expect_any_instance_of(AWS::DynamoDB::Client::V20120810).to_not receive(:initialize)

        expect_any_instance_of(AWS::DynamoDB::Client::V20120810).to_not receive(:query)

        table = double().as_null_object
        expect(table).to receive(:table_name).and_return("table_name").twice

        config = { "elasticache_config_endpoint" => "/cache" }

        instance = subject.new(table, config)
        lookup = instance.read("id", {:variant => "foo"}, 0)

        expect(lookup.location).to eq("/location")
      end
    end

    describe "#write" do
      it "does not fail" do
        lookup_table = double().as_null_object

        expect(lookup_table)
          .to receive(:table_name)
          .and_return('test')

        expect(lookup_table)
          .to receive(:write)
          .with(
            "id/7e0c33c476b1089500d5f172102ec03e",
            "0",
            "/location"
          )

        expect_any_instance_of(Alephant::Lookup::LookupHelper)
          .to receive(:lookup_table)
          .and_return(lookup_table)

        instance = subject.new(lookup_table)
        instance.write("id",{},"0","/location")
      end
    end

    describe "#truncate!" do
      it "deletes all table rows" do
        table = double()
        expect(table).to receive(:table_name)
        expect(table).to receive(:truncate!)

        subject = Alephant::Lookup::LookupHelper.new(table)
        subject.truncate!
      end
    end
  end
end
