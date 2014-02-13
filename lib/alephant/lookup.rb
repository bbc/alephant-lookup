require "alephant/lookup/version"
require "alephant/lookup/lookup"
require "alephant/lookup/lookup_table"

module Alephant
  module Lookup
    @@lookup_tables = {}

    def self.create(table_name, component_id)
      @@lookup_tables[table_name] ||= LookupTable.new('table_name')
      Lookup.new(@@lookup_tables[table_name], component_id)
    end
  end
end
