# Life::API

A Ruby interface to the life:) API. Use this gem at your own risk.

[life:)]: http://life.com.ua — GSM operator in Ukraine.

## Installation

Add this line to your application's Gemfile:

```
gem 'life-api'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install life-api
```

## Usage

First of all require the `life-api` library.

```ruby
require 'life-api'
```

### Authentication

You can authenticate with life:) in two ways: with password or with token.

Authentication with password to the life:) API is accomplished using an Phone number(`msisdn`) and SuperPassword(`password`).

```ruby
life = Life::API.new(msisdn: msisdn, password: password)
life.sign_in
token = life.token
sub_id = life.sub_id
```

> To obtain the SuperPassword send an SMS with key word PASSWORD to number 125, or enter life:) menu by dialing `*125#`, choose Manage account and then SuperPassword service or call `*125*779#`.

or

```ruby
life = Life::API.new
life.token = token
life.sub_id = sub_id
```

Now you can make requests to the API.

## Supported Rubies

Tested with the following Ruby versions:

* MRI 1.9.3

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License and Author

Copyright (c) 2013 by Anton Maminov

This library is distributed under the MIT license. Please see the LICENSE file.
