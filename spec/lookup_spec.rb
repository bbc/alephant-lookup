require "spec_helper"

describe Alephant::Lookup do
  describe ".create" do
    subject { Alephant::Lookup }

    it "returns a lookup" do
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
          :table_name => 'table_name',
          :consistent_read => true,
          :projection_expression => '#loc',
          :expression_attribute_names => {
            '#loc' => 'location'
          },
          :key_condition_expression => 'component_key = :component_key AND batch_version = :batch_version',
          :expression_attribute_values => {
            ':component_key' => 'id/7ef6e03f709c7e6b1c87bcf908bc5e0e',
            ':batch_version' => 0 # @TODO: Verify if this is nil as this would be 0
          }
        }
      end

      let(:cache_client) { Dalli::Client.new }

      it "queries DynamoDb and returns a location when not in cache" do
        expect(Dalli::Client).to receive(:new).and_return(cache_client)

        expect(cache_client).to receive(:get)
        expect(cache_client).to receive(:set)

        expect_any_instance_of(Aws::DynamoDB::Client)
          .to receive(:query)
          .with(expected_query)
          .and_return(double(count: 1, items: [{ "location" => "/location"}]))

        table = double().as_null_object
        expect(table).to receive(:table_name).and_return("table_name").exactly(4).times

        config = { "elasticache_config_endpoint" => "/cache" }

        instance = subject.new(table, config)
        lookup = instance.read("id", {:variant => "foo"}, 0)

        expect(lookup.location).to eq("/location")
      end

      it "reads location from the cache when in cache" do
        lookup_location = Alephant::Lookup::LookupLocation.new("id", {:variant => "foo"}, 0, "/location")

        expect(Dalli::Client).to receive(:new).and_return(cache_client)

        expect(cache_client).to receive(:get)
          .with("table_name/id/7ef6e03f709c7e6b1c87bcf908bc5e0e/0")
          .and_return(lookup_location)
        expect(cache_client).to_not receive(:set)

        expect_any_instance_of(Aws::DynamoDB::Client).to_not receive(:query)

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
            "id/c1d9f50f86825a1a2302ec2449c17196",
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
