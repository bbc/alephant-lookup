require 'spec_helper'

describe Alephant::Lookup do
  describe '.create(table_name, component_id)' do
    it 'returns a lookup' do
      Alephant::Lookup::LookupHelper
        .any_instance
        .stub(:initialize)

      expect(subject.create(:table_name)).to be_a Alephant::Lookup::LookupHelper
    end
  end

  describe Alephant::Lookup::LookupHelper do
    subject { Alephant::Lookup::LookupHelper }

    describe '#initialize(table_name)' do
      it 'calls create on lookup_table' do
        table = double()
        table.should_receive(:create)
        subject.new(table)
      end
    end

    describe '#read(id, opts, batch_version)' do
      let(:expected_query) do
        {
          :table_name=>"table_name",
          :consistent_read=>true,
          :select=>"SPECIFIC_ATTRIBUTES",
          :attributes_to_get=>["location"],
          :key_conditions=>{
            "component_key"=> {
              :comparison_operator=>"EQ",
              :attribute_value_list=>[{"s"=>"id/9dd916afd5516828a91d259967fd394a"}]
            },
            "batch_version"=>{
              :comparison_operator=>"EQ",
              :attribute_value_list=>[{"n"=>"{:variant=>\"foo\"}"}]
            }
          }
        }
      end

      it 'queries DynamoDb and returns a location' do
        AWS::DynamoDB::Client::V20120810
          .any_instance
          .stub(:initialize)

        AWS::DynamoDB::Client::V20120810
          .any_instance
          .should_receive(:query)
          .with(expected_query)
          .and_return(
            {
              :count => 1,
              :member => [
                { 'location' => { :s => '/location' } }
              ]
            }
          )

        table = double().as_null_object
        table.stub(:table_name).and_return('table_name')

        instance = subject.new(table)
        lookup = instance.read('id',{:variant => "foo"},0)

        expect(lookup.location).to eq('/location')
      end
    end

    describe '#write(opts, location)' do
      it 'does not fail' do
        AWS::DynamoDB
          .any_instance
          .stub(:initialize)
          .and_return(
            double().as_null_object
          )

        pending
      end
    end
  end
end
