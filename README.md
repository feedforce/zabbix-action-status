# Zabbix::Action::Status [![Gem Version][gem-badge]][gem-link]

Toggle Zabbix Actions.

This gem is checked on Zabbix version 2.0.14.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'zabbix-action-status'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install zabbix-action-status

## Usage

```ruby
# 4 and 8 are action_ids
zabbix_action_status = Zabbix::Action::Status.new('http://example.com/api_jsonrpc.php', %w(4 8))

zabbix_action_status.disable
zabbix_action_status.enable
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment. 

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/feedforce/zabbix-action-status/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[gem-badge]: https://badge.fury.io/rb/zabbix-action-status.svg
[gem-link]: http://badge.fury.io/rb/zabbix-action-status
