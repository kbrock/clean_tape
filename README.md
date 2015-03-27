# CleanTape

To test ruby code that accesses remote services, many people use [vcr](https://github.com/vcr/vcr).
Unfortunatly, private values creep into our vcr cassettes yaml files.
Also, when we record new cassettes, it says a bunch of values have changed that
don't really mean much. Like the time the response took on the server or
the date the server responded.

This cleans those values so cassettes are with minimal private information and dates are normalized to help reduce the number of lines that are said to change from one casset to the next.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'clean_tape'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install clean_tape

## Usage

```bash
clean_tape spec/cassets/*.yml
```

## Contributing

1. Fork it ( https://github.com/kbrock/clean_tape/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
