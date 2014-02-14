require 'spec_helper'

describe Alephant::Lookup do
  describe '.create(table_name, component_id)' do
    it 'returns a lookup' do
      Alephant::Lookup::Lookup
        .any_instance
        .stub(:initialize)
        .and_return(double())

      expect(subject.create(:table_name, :component_id)).to be_a Alephant::Lookup::Lookup
    end
  end

  describe Alephant::Lookup::Lookup do
    subject { Alephant::Lookup::Lookup }

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

      it 'returns lookup_table.location_for(component_id, opts_hash)' do
        subject
          .any_instance
          .stub(:create_lookup_table)

        lookup_table
          .any_instance
          .stub(:initialize)

        lookup_table
          .any_instance
          .stub(:location_for)
          .and_return(s3_location)

        pal_opts = {
          :id   => :england_council_election_results,
          :env  => :test,
          :type => :responsive
        }

        hash_opts     = Crimp.signature(pal_opts)
        instance      = subject.new(lookup_table.new, pal_opts[:id])
        read_location = instance.read(hash_opts)

        expect(read_location).to eq(s3_location)
      end
    end

    describe '#write(opts, location)' do
      it 'calls lookup_table.location_for(component_id, opts_hash, data)' do
        pending
      end
    end
  end
end
