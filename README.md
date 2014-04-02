# Alephant::Lookup

Lookup a location in S3 using DynamoDB.

[![Build
Status](https://travis-ci.org/BBC-News/alephant-lookup.png)](https://travis-ci.org/BBC-News/alephant-lookup)

[![Gem
Version](https://badge.fury.io/rb/alephant-lookup.png)](http://badge.fury.io/rb/alephant-lookup)

## Installation

Add this line to your application's Gemfile:

    gem 'alephant-lookup'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install alephant-lookup

## Usage

```rb
require "alephant/lookup"
# => true

AWS.config.region
# => "us-east-1"

AWS.config(:region => 'eu-west-1')
# => <AWS::Core::Configuration>

AWS.config.region
# => "eu-west-1"

lookup = Alephant::Lookup.create("mark_lookup_test")
# => #<Alephant::Lookup::LookupHelper:0x1f881554
#     @lookup_table=
#      #<Alephant::Lookup::LookupTable:0x7f8dd355
#       @config={:write_units=>5, :read_units=>10},
#       @dynamo_db=<AWS::DynamoDB>,
#       @mutex=#<Mutex:0x6a3f8a94>,
#       @range_found=false,
#       @table=<AWS::DynamoDB::Table table_name:mark_lookup_test>,
#       @table_name="mark_lookup_test">>

dynamo_db = AWS::DynamoDB.new
# => <AWS::DynamoDB>

dynamo_db.tables["mark_lookup_test"].exists?
# => true

table = dynamo_db.tables["mark_lookup_test"]
# => <AWS::DynamoDB::Table table_name:mark_lookup_test>

table.status
# => :active

table.items.count
# => 0

table.items
# => <AWS::DynamoDB::ItemCollection>

table.items.put({ :component_key => "a/b", :batch_version => 1, :location => "a/c/b/1" })
# => <AWS::DynamoDB::Item table_name:mark_lookup_test hash_value:a/b range_value:0.1E1>

table.items.put({ :component_key => "d/e", :batch_version => 1, :location => "d/f/e/1" })
# => <AWS::DynamoDB::Item table_name:mark_lookup_test hash_value:d/e range_value:0.1E1>

lookup.truncate!
# => nil

component_id  = "foo"
opts          = { :key => :value }
batch_version = 1
location      = "s3-bucket/location"

lookup.write(id, opts, batch_version, location)
lookup.read(id, opts, batch_version)
```

## Contributing

1. Fork it ( http://github.com/BBC-News/alephant-lookup/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
