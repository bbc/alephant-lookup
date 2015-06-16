require "alephant/lookup/version"
require "alephant/lookup/lookup_helper"
require "alephant/lookup/lookup_table"

require 'alephant/logger'
require 'alephant/logger/json'

json_driver = Alephant::Logger::JSON.new(ENV["APP_LOG_LOCATION"] ||= "app.log")
Alephant::Logger.setup json_driver

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
