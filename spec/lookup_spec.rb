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
      it 'does not fail' do
        pending
      end
    end

    describe '#write(opts, location)' do
      it 'does not fail' do
        pending
      end
    end
  end
end
