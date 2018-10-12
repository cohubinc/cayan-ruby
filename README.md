# Cayan

A Ruby gem for talking to the Cayan Merchantware API

[![Build Status](https://travis-ci.com/cohubinc/cayan-ruby.svg?branch=master)](https://travis-ci.com/cohubinc/cayan-ruby)
[![Coverage Status](https://coveralls.io/repos/github/cohubinc/cayan-ruby/badge.svg?branch=master)](https://coveralls.io/github/cohubinc/cayan-ruby?branch=master)

## Installation (not published yet)

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

## Merchantware Credit Usage

- [Initialize a Merchantware Credit Client](#initialize-a-merchantware-credit-client)
- [AdjustTip](#adjusttip)
- [AttachSignature](#attachsignature)
- [Authorize](#authorize)
- [BoardCard](#boardcard)
- [Capture](#capture)
- [FindBoardedCard](#findboardedcard)
- [UpdateBoardedCard](#updatedboardedcard)
- [ForceCapture](#forcecapture)
- [Refund](#refund)
- [Sale](#sale)
- [SettleBatch](#settlebatch)
- [UnboardCard](#unboardcard)
- [Void](#void)

### Initialize a Merchantware Credit Client

```ruby
@client = Cayan::Merchantware::Credit::Client.new({
  merchant_name: 'Zero Inc',
  merchant_site_id: '00000000',
  merchant_key: '00000-00000-00000-00000-00000'
})
```

### AdjustTip

Adds or alters the tip amount to a prior transaction

```ruby
result = @client.adjust_tip({ token: '1236559', amount: '1.00' })

result[:approval_status] # 'APPROVED'
result[:token] # '1236560'
result[:transaction_date] # '3/14/2016 7:54:23 PM'
```

### AttachSignature

Appends a signature record to an existing transaction

```ruby
result = @client.attach_signature({
  token: '608957',
  vector_image_data: '10,10^110,110^0,65535^10,110^110,10^0,65535^~'
})

result[:upload_status] # 'ACCEPTED'
result[:token] # '608957'
result[:transaction_date] # '3/14/2016 7:57:32 PM'
```

### Authorize

Applies an authorization to a credit card which can be captured at a later time

```ruby
result = @client.authorize({
  source: 'Keyed',
  card_number: '4012000033330026',
  expiration_date: '1218',
  card_holder: 'John Doe',
  avs_street_address: '1 Federal Street',
  avs_zip_code: '02110',
  card_verification_value: '123'
},
{
  amount: 1.05,
  invoice_number: '1556',
  register_number: '35',
  merchant_transaction_id: '167901',
  card_acceptor_terminal_id: '3'
})

result[:approval_status] # 'APPROVED'
result[:token] # '608958'
result[:authorization_code] # 'OK785C'
result[:transaction_date] # '3/14/2016 7:58:33 PM'
result[:amount] # '1.05'
result[:card_number] # '************0026'
result[:cardholder] # 'John Doe'
result[:card_type] # '4'
result[:reader_entry_mode] # '1'
result[:avs_response] # 'Y'
```

### BoardCard

Stores payment information for a credit card into the Merchantware Vault

```ruby
result = @client.board_card({
  source: 'Keyed',
  card_number: '4012000033330026',
  expiration_date: '1218',
  card_holder: 'John Doe',
  avs_street_address: '1 Federal Street',
  avs_zip_code: '02110'
})

result[:vault_token] # '1000000000002WSZECPL'
```

### Capture

Completes a transaction for a prior authorization

```ruby
result = @client.capture({
  token: '608939',
  amount: 1.50,
  invoice_number: '1556',
  register_number: '35',
  merchant_transaction_id: '167902',
  card_acceptor_terminal_id: '3'
})
result[:approval_status] # 'APPROVED'
result[:token] # '608961'
result[:authorization_code] # 'OK036C'
result[:transaction_date] # '3/14/2016 8:09:31 PM'
result[:amount] # '1.50'
```

### FindBoardedCard

Retrieves the payment data stored inside the Merchantware Vault

```ruby
result = @client.find_boarded_card({ vault_token: '127MMEIIQVEW2WSZECPL' })

result[:card_number] # '0026'
result[:expiration_date] # '1218'
result[:card_type] # '4'
result[:avs_street_address] # '1 Federal Street'
result[:avs_zip_code] # '02110'
```

### UpdateBoardedCard

Changes the expiration date for an existing payment method stored inside the Merchantware Vault

```ruby
result = @client.update_boarded_card({
  token: '127MMEIIQVEW2WSZECPL',
  expiration_date: '0118'
})

result[:vault_token] # '127MMEIIQVEW2WSZECPL'
```

### ForceCapture

Forces a charge to be issued upon a customer’s credit card

```ruby
result = @client.force_capture(
  {
    source: 'Keyed',
    card_number: '4012000033330026',
    expiration_date: '1218',
    card_holder: 'John Doe'
  }, {
    amount: '3.06',
    authorization_code: 'V00546C',
    invoice_number: '1559',
    register_number: '35',
    merchant_transaction_id: '168901',
    card_acceptor_terminal_id: '3',
    ecommerce_transaction_indicator: nil
  }
)

result[:approval_status] # 'APPROVED'
result[:token] # '608962'
result[:authorization_code] # 'V00546C'
result[:transaction_date] # '3/14/2016 8:11:01 PM'
result[:amount] # '3.06'
result[:card_number] # '************0026'
result[:cardholder] # 'John Doe'
result[:card_type] # '4'
```

### Refund

Issues a credit card refund to a customer.

```ruby
result = @client.refund(
  {
    source: 'Keyed',
    card_number: '4012000033330026',
    expiration_date: '1218',
    card_holder: 'John Doe'
  }, {
    amount: '4.01',
    invoice_number: '1701',
    register_number: '35',
    merchant_transaction_id: '165901',
    card_acceptor_terminal_id: '3',
    ecommerce_transaction_indicator: nil
  }
)

result[:approval_status] # 'APPROVED'
result[:token] # '608963'
result[:transaction_date] # '3/14/2016 8:12:50 PM'
result[:amount] # '4.01'
result[:card_number] # '************0026'
result[:cardholder] # 'John Doe'
result[:card_type] # '4'
```

### Sale

Charges a credit or debit card

```ruby
result = @client.sale(
  {
    source: 'Keyed',
    card_number: '4012000033330026',
    expiration_date: '1218',
    card_holder: 'John Doe',
    avs_street_address: '1 Federal Street',
    avs_zip_code: '02110',
    card_verification_value: '123'
  }, {
    amount: '1.05',
    cashback_amount: '0.00',
    surcharge_amount: '0.00',
    tax_amount: '0.00',
    invoice_number: '1556',
    purchase_order_number: '17801',
    customer_code: '20',
    register_number: '35',
    merchant_transaction_id: '166901',
    card_acceptor_terminal_id: '3',
    enable_partial_authorization: 'False',
    force_duplicate: 'False',
    ecommerce_transaction_indicator: nil
  }
)

result[:approval_status] # 'APPROVED'
result[:token] # '608957'
result[:authorization_code] # 'OK775C'
result[:transaction_date] # '3/14/2016 7:57:22 PM'
result[:amount] # '1.05'
result[:card_number] # '************0026'
result[:cardholder] # 'John Doe'
result[:card_type] # '4'
result[:avs_response] # 'Y'
```

### SettleBatch

Batches out a merchant’s outstanding transactions for settlement.

```ruby
result = @client.settle_batch

result[:batch_status] # 'SUCCESS'
result[:authorization_code] # '0314160001'
result[:batch_amount] # '2.19'
result[:transaction_count] # '8'
result[:transaction_date] # '3/14/2016 8:28:30 PM'
```

### UnboardCard

Removes existing payment information from the Merchantware Vault

```ruby
result = @client.unboard_card({ vault_token: "MYTOKENVALUEX" })

result[:vault_token] # 'MYTOKENVALUEX'
```

### Void

Voids a prior unsettled transaction

```ruby
result = @client.void({
  token: "608973",
  register_number: '35',
  merchant_transaction_id: '167901',
  card_acceptor_terminal_id: '3'
})

result[:approval_status] # 'APPROVED'
result[:token] # '608974'
result[:authorization_code] # 'VOID'
result[:transaction_date] # '3/14/2016 8:30:18 PM'
```

All Credit transactions are supported. Check and GiftCard transactions coming soon.
[Cayan Merchantware API Docs](https://cayan.com/developers/merchantware/merchantware-4-5/credit)

##

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/cohubinc/cayan-ruby.
