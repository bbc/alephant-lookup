require "alephant/lookup/version"
require "alephant/lookup/lookup_helper"
require "alephant/lookup/lookup_table"

require "alephant/logger"

module Alephant
  module Lookup
    include Logger
    @@lookup_tables = {}

    def self.create(table_name)
      @@lookup_tables[table_name] ||= LookupTable.new(table_name)
      LookupHelper.new(@@lookup_tables[table_name])
    end
  end
end
