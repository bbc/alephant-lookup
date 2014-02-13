require 'spec_helper'

describe Alephant::Lookup do
  describe '.create(table_name, component_id)' do
    it 'returns a lookup' do
      expect(subject.create(:table_name, :component_id)).to be_a Alephant::Lookup::Lookup
    end
  end

  describe Alephant::Lookup::Lookup do
    describe '#initialize(table_name)' do
      it 'calls create on lookup_table' do
        table = double()
        table.should_receive(:create)

        Alephant::Lookup::Lookup.new(table, :component_id)
      end
    end

    describe '#read(opts)' do
      it 'returns lookup_table.location_for(component_id, opts_hash)' do
        fail
      end
    end

   describe '#write(opts, location)' do
      it 'calls lookup_table.location_for(component_id, opts_hash, data)' do
        fail
      end
    end

  end
end

