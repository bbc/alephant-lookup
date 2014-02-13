# Alephant::Lookup

Lookup a location in S3 using DynamoDB.

[![Build
Status](https://travis-ci.org/BBC-News/alephant-lookup.png)](https://travis-ci.org/BBC-News/alephant-lookup)

[![Gem
Version](https://badge.fury.io/rb/alephant-lookup.png)](http://badge.fury.io/rb/alephant-lookup)

Add this line to your application's Gemfile:

    gem 'alephant-lookup'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install alephant-lookup

## Usage

```rb
require 'alephant-lookup'

lookup = Alephant::Lookup.create('table_name', 'component_id')

opts = { :key => :value }

location = "s3-bucket/location"
lookup.write(opts, location)

lookup.read(opts)
# => s3-bucket/location
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/alephant-lookup/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
