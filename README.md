# lifecell::API

[![Gem Version](https://badge.fury.io/rb/lifecell_api.svg)](https://badge.fury.io/rb/lifecell_api)
[![Ruby](https://github.com/mamantoha/lifecell_api/actions/workflows/ruby.yml/badge.svg)](https://github.com/mamantoha/lifecell_api/actions/workflows/ruby.yml)
[![Rubocop](https://github.com/mamantoha/lifecell_api/actions/workflows/rubocop.yml/badge.svg)](https://github.com/mamantoha/lifecell_api/actions/workflows/rubocop.yml)

A Ruby library for interfacing with lifecell's undocumented/unannounced API.

Formerly known as `life-api`.

[lifecell](http://lifecell.com.ua) — GSM operator in Ukraine.

## Installation

Add this line to your application's Gemfile:

```
gem 'lifecell_api'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install lifecell_api
```

## Usage

First of all require the `lifecell_api` library.

```ruby
require 'lifecell_api'
```

### Authentication

You can authenticate with lifecell in two ways: with password or with token.

Authentication with password to the lifecell API is accomplished using a phone number(`msisdn`) starting with the country code("380"), and SuperPassword(`password`).

```ruby
msisdn = '38063xxxxxxx'
password = 'xxxxxx'

life = Lifecell::API.new(msisdn: msisdn, password: password)
life.sign_in
token = life.token
sub_id = life.sub_id
```

> To obtain the SuperPassword send an SMS with key word PAROL to number 123.

or

```ruby
life = Lifecell::API.new
life.token = token
life.sub_id = sub_id
```

Now you can make requests to the API.

### API Examples

Below you can see some the methods for working with lifecell data.

#### Returns advanced information on the current subscriber

```ruby
life.summary_data
```

Sample response

```ruby
{"method"=>"getSummaryData",
 "responseCode"=>"0",
 "subscriber"=>
  {"attribute"=>
    [{"name"=>"ICCID", "content"=>"89380062300016907xxx"},
     {"name"=>"PUK", "content"=>"25159xxx"},
     {"name"=>"PUK2", "content"=>"00036xxx"},
     {"name"=>"PIN2", "content"=>"55xx"},
     {"name"=>"IMSI", "content"=>"25506109310xxxx"},
     {"name"=>"PIN", "content"=>"70xx"},
     {"name"=>"LINE_STATE", "content"=>"ACT/STD"},
     {"name"=>"USE_COMMON_MAIN", "content"=>"false"},
     {"name"=>"LINE_ACTIVATION_DATE",
      "content"=>"2010-03-02T11:28:07.392+02:00"},
     {"name"=>"LANGUAGE_ID", "content"=>"uk_tr"},
     {"name"=>"DEVICE_NAME", "content"=>"HTC Sensation (PG58130)"},
     {"name"=>"LINE_SUSPEND_DATE", "content"=>"2014-03-21T00:00:00+02:00"}],
   "balance"=>
    [{"code"=>"Line_Main", "amount"=>"12.83"},
     {"code"=>"Line_Bonus", "amount"=>"0.00"},
     {"code"=>"Line_Debt", "amount"=>"0.00"}],
   "bundleFreeMigration"=>{"amount"=>"0"},
   "tariff"=>{"code"=>"IND_PRE_YOUTH", "name"=>"Crazy day"}}}
```

#### Returns the balance of the current subscriber

```ruby
life.balances
```

Sample response

```ruby
{"method"=>"getBalances",
 "responseCode"=>"0",
 "balance"=>
  [{"code"=>"Bundle_Gprs_Internet",
    "amount"=>"0.00",
    "measure"=>"Bytes",
    "name"=>"Free Internet"},
   {"code"=>"Bundle_Gprs_Wap",
    "amount"=>"0.00",
    "measure"=>"Bytes",
    "name"=>"Free Internet [WAP]"},
   {"code"=>"Bundle_Gprs_Internet_Youth",
    "amount"=>"32624640.00",
    "measure"=>"Bytes",
    "name"=>"Internet [Crazy Day]"},
   {"code"=>"Bundle_Usage_Internet_Weekly",
    "amount"=>"0.00",
    "measure"=>"Bytes",
    "name"=>"Used Internet [Week]"},
   {"code"=>"Bundle_Mms_Ukraine",
    "amount"=>"0.00",
    "measure"=>"MMS",
    "name"=>"Free MMS [in Ukraine]"},
   {"code"=>"Bundle_Sms_Ukraine",
    "amount"=>"40.00",
    "measure"=>"SMS",
    "name"=>"Free SMS [in Ukraine]"},
   {"code"=>"Bundle_Youth_Voice_Omo_Pstn",
    "amount"=>"2160.00",
    "measure"=>"Seconds",
    "name"=>"100 min «life:) Сrazy day maximum» [other mob operators]"},
   {"code"=>"Bundle_UsageN_FF_FREE",
    "amount"=>"0.00",
    "measure"=>"Seconds",
    "name"=>"Free minutes [Family Numbers]"},
   {"code"=>"Bundle_UsageN_Onnet_Region",
    "amount"=>"0.00",
    "measure"=>"Seconds",
    "name"=>"Free minutes [Free life:) Donbas]"},
   {"code"=>"Bundle_Voice_Onnet",
    "amount"=>"24000.00",
    "measure"=>"Seconds",
    "name"=>"Free minutes [life:) network]"},
   {"code"=>"Bundle_Voice_Offnet",
    "amount"=>"0.00",
    "measure"=>"Seconds",
    "name"=>
     "Free minutes [other mobile operators and fixed numbers of Ukraine]"},
{"code"=>"Line_Bonus",
    "amount"=>"0.00",
    "measure"=>"UAH",
    "name"=>"Line Bonus"},
   {"code"=>"Line_Main",
    "amount"=>"12.83",
    "measure"=>"UAH",
    "name"=>"Line Main"}]}
```

#### Returns payments history for calendar month in format 'YYYY-mm'

```ruby
life.payments_history('2013-03')
```

Sample response

```ruby
{"method"=>"getPaymentsHistory",
 "responseCode"=>"0",
 "payments"=>
  {"sum"=>"50.00",
   "payment"=>
    [{"date"=>"2013-03-21",
      "time"=>"10:40:12",
      "type"=>"Payment via WEB",
      "sum"=>"10.00"},
     {"date"=>"2013-03-21",
      "time"=>"13:25:28",
      "type"=>"Payment via WEB",
      "sum"=>"40.00"}]}}
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License and Author

Copyright (c) 2013-2026 by Anton Maminov

This library is distributed under the MIT license. Please see the LICENSE file.
