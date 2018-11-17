# Miller

Write beautiful and descriptive code by adding configurable services with DSLs
in a quick and easy manner.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'miller'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install miller

## Usage

```ruby
class ServiceBase
  include Miller.with(:name, :lastname)
  def full_name
    "#{name} #{lastname}"
  end
  # write your logic here
end

class Service < ServiceBase
  name 'John'
  lastname 'Doe'
end

Service.config.name # => 'John'
Service.config.lastname # => 'Doe'
inst = Service.new
inst.name # => 'John'
inst.lastname # => 'Doe'
inst.full_name # => 'John Doe'
```

__IMPORTANT:__ Usually you will create a base class and then inherit from it for clarity as the previous example shows. The following examples are just to explain the features.

### Errors

```ruby
  class Service
    include Miller.with(:name, :lastname)
    name 'John'
    lastname 'Doe'
  end
  Service.config.foo # => Miller::ConfigNotSetError
```
### Blocks

```ruby
  class Service
    include Miller.with(:name, :lastname)
    name { another_name }
    lastname 'Doe'

    def another_name
      "victor"
    end
  end
  Service.config.name # => Proc
  Service.config.lastname # => 'Doe'
  inst = Service.new
  inst.name # => 'victor'
  inst.lastname # => 'Doe'
```

### Default Config

```ruby
  class Service
    include Miller.with(:name, :lastname, default_config: { name: 'Henry', lastname: 'Miller' })
    lastname 'Doe'
  end
  Service.config.name # => 'Henry'
  Service.config.lastname # => 'Doe'
  inst = Service.new
  inst.name # => 'Henry'
  inst.lastname # => 'Doe'
```

### Inheritance

If you require configs to be inherited by children use the following.

```ruby
  class ServiceBase < Miller.base(:name, :lastname)
    name 'John'
    lastname 'Doe'
  end
  class Service < ServiceBase; end
  Service.config.name # => 'John'
  Service.config.lastname # => 'Doe'
  inst = Service.new
  inst.name # => 'John'
  inst.lastname # => 'Doe'
```

### Override at instance level

__WARNING:__ This can be useful but very dangerous please use it carefully.

```ruby
  class Service
    include Miller.with(:name, :lastname)
    name 'John'
    lastname 'Doe'
  end
  Service.config.name # => 'John'
  Service.config.lastname # => 'Doe'
  inst = Service.new
  inst.name = 'Henry'
  inst.name # => 'Henry'
  inst.lastname # => 'Doe'
```

```ruby
  class Service
    include Miller.with(:name, :lastname)
    name 'John'
    lastname 'Doe'
    def another_name
      'Martha'
    end
  end
  Service.config.name # => 'John'
  Service.config.lastname # => 'Doe'
  inst = Service.new
  inst.name = proc { another_name }
  inst.name # => 'Martha'
  inst.lastname # => 'Doe'
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/miller. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Miller project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/miller/blob/master/CODE_OF_CONDUCT.md).
