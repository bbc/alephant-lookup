require 'spec_helper'

describe Alephant::Lookup do
  describe '.create(table_name, component_id)' do
    it 'returns a lookup' do
      Alephant::Lookup::LookupHelper
        .any_instance
        .stub(:initialize)
        .and_return(double())

      expect(subject.create(:table_name, :component_id)).to be_a Alephant::Lookup::LookupHelper
    end
  end

  describe Alephant::Lookup::LookupHelper do
    subject { Alephant::Lookup::LookupHelper }

    describe '#initialize(table_name)' do
      it 'calls create on lookup_table' do
        table = double()
        table.should_receive(:create)
        subject.new(table, :component_id)
      end
    end

    describe '#read(opts)' do
      let (:lookup_table) { Alephant::Lookup::LookupTable }
      let (:s3_location)  { '/s3-render-example/test/html/england_council_election_results/responsive' }
      let (:location_read){ Alephant::Lookup::LocationRead }

      it 'returns correct S3 Location' do
        subject
          .any_instance
          .stub(:create_lookup_table)

        lookup_table
          .any_instance
          .stub(:initialize)

        location = Alephant::Lookup::LookupLocation.new(:component_id,:opts_hash, s3_location)

        location_read
          .any_instance
          .stub(:read)
          .and_return(location)

        pal_opts = {
          :id   => :england_council_election_results,
          :env  => :test,
          :type => :responsive
        }

        instance      = subject.new(lookup_table.new, pal_opts[:id])
        read_location = instance.read(pal_opts)

        expect(read_location).to eq(s3_location)
      end
    end

    describe '#write(opts, location)' do

      let (:lookup_table)  { Alephant::Lookup::LookupTable }
      let (:s3_location)   { '/s3-render-example/test/html/england_council_election_results/responsive' }
      let (:location_write){ Alephant::Lookup::LocationWrite }

      it 'returns lookup_table.update_location_for(component_id, opts_hash, data)' do

        subject
          .any_instance
          .stub(:create_lookup_table)

        lookup_table
          .any_instance
          .stub(:initialize)

        lookup_table
          .any_instance
          .stub(:table_name)
          .and_return('table_name')

        pal_opts = {
          :id   => :england_council_election_results,
          :env  => :test,
          :type => :responsive
        }

        AWS::DynamoDB::BatchWrite
          .any_instance
          .should_receive(:put)
          .with(
            'table_name',
              [
                {
                  :component_id=> :england_council_election_results,
                  :opts_hash=>"52a25baaaa8c4527ddc869feaa285c3a",
                  "location"=>:s3_location
                }
              ]
          )

        AWS::DynamoDB::BatchWrite
          .any_instance
          .should_receive(:process!)

        instance      = subject.new(lookup_table.new, pal_opts[:id])
        write_return  = instance.write(pal_opts, :s3_location)

        expect(write_return).to eq(true)
      end
    end
  end
end
