# Cayan

A Ruby gem for talking to the Cayan Merchantware API

[![Build Status](https://travis-ci.com/cohubinc/cayan-ruby.svg?branch=master)](https://travis-ci.com/cohubinc/cayan-ruby)
[![Coverage Status](https://coveralls.io/repos/github/cohubinc/cayan-ruby/badge.svg?branch=master)](https://coveralls.io/github/cohubinc/cayan-ruby?branch=master)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cayan'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install cayan
```

## Usage

```ruby
@client = Cayan::Merchantware::Credit::Client.new({
  merchant_name: 'Zero Inc',
  merchant_site_id: '00000000',
  merchant_key: '00000-00000-00000-00000-00000'
})

result = @client.board_card({
  source: 'Keyed',
  card_number: '4012000033330026',
  expiration_date: '1218',
  card_holder: 'John Doe',
  avs_street_address: '1 Federal Street',
  avs_zip_code: '02110'
})
```

All Credit transactions are supported. Check and GiftCard transactions coming soon.
[Cayan Merchantware API Docs](https://cayan.com/developers/merchantware/merchantware-4-5/credit)

##

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cohubinc/cayan-ruby.
