# Xpect

A Ruby Hash specification to ensure unstructured data is structured the way you expect it.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'xpect'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install xpect

## Usage

Verify that `Hash`es are the structure you expect at the on-set, as opposed to finding out a `Hash` isn't structured
the way you intended deep in a function body. This can be useful for various reasons, such as:
  * HTTP responses
  * RabbitMQ payloads
  * Argument Hashes
  * Or, anywhere that needs to ensure `Hash`es (or JSON, just parse it first) conform to a particular structure

```ruby
def some_function(hash_payload)
  spec = {
    person: {
      first_name: Xpect::Matchers.truthy,
      last_name: Xpect::Matchers.truthy,
      footwear: lambda {|v| ['flip flops', 'flip flops and socks', 'hiking boots'].include?(v) },
      state: 'GA'
    }
  }
  
  Xpect::Spect.validate!(spec: spec, data: hash_payload)
  
  # Continue processing data knowing that the Hash contains valid data.
end

```

## `.conform!` vs `.validate!`

`.validate!` ensures the data (i.e. the `Hash`) adheres to the structure according to the spec (i.e. validates the data).
If the data is valid then it returns the data it was given. `.conform!` validates the data according to the spec, just like
`.validate!`, but it returns only the data specified in the spec. Both functions raise a `Xpect::FailedSpec` if the data
does not adhere to the structure of the spec.

### `.validate!`

```ruby
spec = {
  name: 'Andre 3000',
  age: lambda {|v| v > 40 }
}

# Passes
validated_data = Xpect::Spect.validate!(
  spec: spec,
  data: {
    name: 'Andre 3000',
    age: 47,
    footwear: 'flip flops and socks'
  }
)

puts validated_data
# {
#  name: 'Andre 3000',
#  age: 47,
#  foot_wear: 'flip flops and socks'
# }

# Fails and raises Xpect::FailedSpec
Xpect::Spect.validate!(
  spec: spec,
  data: {
    name: 'Andre 3000',
    age: 4, # Not greater than 40 as specified in spec
    footwear: 'flip flops and socks'
  }
)
```

### `.conform!`

```ruby
spec = {
  name: 'Andre 3000',
  age: lambda {|v| v > 40 }
}

# Passes
validated_data = Xpect::Spect.conform!(
  spec: spec,
  data: {
    name: 'Andre 3000',
    age: 47,
    footwear: 'flip flops and socks'
  }
)

puts validated_data
# {
#  name: 'Andre 3000',
#  age: 47,
# }

# Fails and raises Xpect::FailedSpec
Xpect::Spect.conform!(
  spec: spec,
  data: {
    name: 'Andre 3000',
    age: 4, # Not greater than 40 as specified in spec
    footwear: 'flip flops and socks'
  }
)
```

## `Hash` values

### `truthy`

```ruby
spec = { name: Xpect::Matchers.truthy }

# Passes
Xpect::Spect.validate!(spec: spec, data: { name: 'Andre 3000'})

# Fails
Xpect::Spect.validate!(spec: spec, data: { name: false})
```

### `falsy`

```ruby
spec = { name: Xpect::Matchers.falsy }

# Passes
Xpect::Spect.validate!(spec: spec, data: { name: ''})

# Fails
Xpect::Spect.validate!(spec: spec, data: { name: 'Andre 3000'})
```

### `anything`

```ruby
spec = { name: Xpect::Matchers.anything }

# Passes
Xpect::Spect.validate!(spec: spec, data: { name: nil})
Xpect::Spect.validate!(spec: spec, data: { name: 'Andre 3000'})

# Fails
Xpect::Spect.validate!(spec: spec, data: {})
```

### `nil`

```ruby
spec = { name: Xpect::Matchers.nil }

# Passes
Xpect::Spect.validate!(spec: spec, data: { name: nil})

# Fails
Xpect::Spect.validate!(spec: spec, data: { name: 'Andre 3000'})
```

### Custom

```ruby
spec = { name: lambda {|v| ['Andre 3000', 'Big Boi'].include?(v) } }

# Passes
Xpect::Spect.validate!(spec: spec, data: { name: 'Big Boi'})
Xpect::Spect.validate!(spec: spec, data: { name: 'Andre'})

# Fails
Xpect::Spect.validate!(spec: spec, data: { name: 'Back Street Boys'})
```

### `Pred`

```ruby
spec = {
  name: Xpect::Pred.new(
    pred: lambda {|v| ['Andre 3000', 'Big Boi'].include?(v) }
  )
}

# Passes
Xpect::Spect.validate!(spec: spec, data: { name: 'Big Boi'})
Xpect::Spect.validate!(spec: spec, data: { name: 'Andre'})

# Fails
Xpect::Spect.validate!(spec: spec, data: { name: 'Back Street Boys'})
```

Providing a default value

```ruby
spec = {
  name: Xpect::Pred.new(
    pred: lambda {|v| ['Andre 3000', 'Big Boi'].include?(v) },
    default: 'Dr. Seuss'
  )
}

# Passes
Xpect::Spect.validate!(spec: spec, data: { name: 'Big Boi'})
Xpect::Spect.validate!(spec: spec, data: { name: 'Andre'})
validated_data = Xpect::Spect.validate!(spec: spec, data: {})

puts validated_data
# { name: 'Dr. Seuss' }

# Fails
Xpect::Spect.validate!(spec: spec, data: { name: 'Back Street Boys'})
```

### Arrays

Exact item comparison

```ruby
spec = {
  people: [
    {
      name: 'Andre 3000',
      footwear: 'flip flops'
    },
    {
      name: 'Big Boi',
      footwear: 'flip flops and socks'
    }
  ]
}

# Passes
Xpect::Spect.validate!(
  spec: spec,
  data: {
    people: [
      {
        name: 'Andre 3000',
        footwear: 'flip flops'
      },
      {
        name: 'Big Boi',
        footwear: 'flip flops and socks'
      }
    ]
  }
)

# Passes
Xpect::Spect.validate!(
  spec: spec,
  data: {
    people: [
      {
        name: 'Andre 3000',
        footwear: 'flip flops'
      },
      {
        name: 'Big Boi',
        footwear: 'flip flops and socks'
      },
      {
        name: 'CeeLo Green',
        footwear: 'boots'
      }
    ]
  }
)

# Fails - missing second item in array in spec
Xpect::Spect.validate!(
  spec: spec,
  data: {
    people: [
      {
        name: 'Andre 3000',
        footwear: 'flip flops'
      }
    ]
  }
)
```

Ensuring every item in Array meets specification

```ruby
spec = {
  people: Xpect::Every.new(
    {
      name: Xpect::Matchers.truthy,
      footwear: lambda {|v| ['flip flops', 'flip flops and socks'].include?(v) }
    }
  )
}

# Passes
Xpect::Spect.validate!(
  spec: spec,
  data: {
    people: [
      {
        name: 'Andre 3000',
        footwear: 'flip flops'
      },
      {
        name: 'Big Boi',
        footwear: 'flip flops and socks'
      }
    ]
  }
)

# Passes
Xpect::Spect.validate!(
  spec: spec,
  data: {
    people: [
      {
        name: 'Andre 3000',
        footwear: 'flip flops'
      },
      {
        name: 'Big Boi',
        footwear: 'flip flops and socks'
      },
      {
        name: 'CeeLo Green',
        footwear: 'flip flops'
      }
    ]
  }
)

# Fails
Xpect::Spect.validate!(
  spec: spec,
  data: {
    people: [
      {
        name: 'Andre 3000',
        footwear: 'flip flops'
      },
      {
        name: 'Big Boi',
        footwear: 'flip flops and socks'
      },
      {
        name: 'Travis',
        footwear: 'Hiking Boots' # footwear does not adhere to specification
      }
    ]
  }
)
````

## `Hash` keys

Requiring keys

```ruby
spec = {
  person: Xpect::Keys.new(
    required: {
      name: 'Andre 3000',
      footwear: lambda {|v| ['flip flops', 'socks'].include?(v) }
    }
  ),
}

# Passes
Xpect::Spect.validate!(
  spec: spec,
  data: {
    person: {
      name: 'Andre 3000',
      footwear: 'socks',
      age: 45
    }
  }
)

# Fails
Xpect::Spect.validate!(
  spec: spec,
  data: {
    person: { 
      footwear: 'socks',
      age: 45  # Missing the `name` key as specified in spec
    }
  }
)
```

Optional keys

```ruby
spec = {
  person: Xpect::Keys.new(
    required: {
      name: 'Andre 3000',
      footwear: lambda {|v| ['flip flops', 'socks'].include?(v) }
    },
    optional: {
      style: 'ice cold'
    }
  ),
}

# Passes
Xpect::Spect.validate!(
  spec: spec,
  data: {
    person: {
      name: 'Andre 3000',
      footwear: 'socks',
      age: 45
    }
  }
)

Xpect::Spect.validate!(
  spec: spec,
  data: {
    person: {
      name: 'Andre 3000',
      footwear: 'socks',
      age: 45,
      style: 'ice cold'
    }
  }
)

# Fails
Xpect::Spect.validate!(
  spec: spec,
  data: {
    person: {
      footwear: 'socks',
      age: 45,
      style: 'too hot for the hot tub' # Does not meet specification
    }
  }
)
```

## Highly Nested Hashes

```ruby
spec = {
  people: Xpect::Every.new(
    {
      name: Xpect::Matchers.truthy,
      footwear: lambda {|v| ['flip flops', 'flip flops and socks'].include?(v) },
      things: [
        1,
        2,
        3,
        {a: 'a'},
        [
          'one',
          'two',
          Xpect::Pred.new(
            pred: lambda {|v| v == 'three'},
            default: 'my-default'
          )
        ]
      ],
      other: Xpect::Keys.new(
        required: {
          b: 'b',
          c: 'c',
          f: [
            4,
            5,
            6,
            lambda {|v| v > 8},
          ],
          g: Xpect::Every.new(
            {
              id: lambda {|v| v > 100}
            }
          )
        },
        optional: {d: 'd', e: 'e'}
      )
    }
  ),
}

# Passes
conformed_data = Xpect::Spect.conform!(
  spec: spec,
  data: {
    people: [
      {
        name: 'Andre 3000',
        footwear: 'flip flops',
        not_required_by_spec: 'not_required_by_spec',
        things: [
          1,
          2,
          3,
          {a: 'a'},
          [
            'one',
            'two'
          ]
        ],
        other: {
          b: 'b',
          c: 'c',
          e: 'e',
          f: [
            4,
            5,
            6,
            9
          ],
          g: [
            {
              id: 101,
            },
            {
              id: 102
            }
          ],
          not_required_by_spec: [1, 2, 3, 4]
        }
      }
    ]
  }
)

puts conformed_data
# {
#  :people => [
#    {
#      :name => "Andre 3000",
#      :footwear => "flip flops",
#      :things => [1, 2, 3, {:a => "a"}, ["one", "two", "my-default"]],
#      :other => {:b => "b", :c => "c", :f => [4, 5, 6, 9], :g => [{:id=>101}, {:id => 102}], :e => "e"}
#    }
#  ]
# }

# Fails
Xpect::Spect.conform!(
  spec: spec,
  data: {
    people: [
      {
        name: 'Andre 3000',
        footwear: 'flip flops',
        not_required_by_spec: 'not_required_by_spec',
        things: [
          1,
          2,
          3,
          {a: 'a'},
          [
            'one',
            'two'
          ]
        ],
        other: {
          b: 'b',
          c: 'c',
          e: 'e',
          f: [
            4,
            5,
            6,
            9
          ],
          g: [
            {
              id: 101,

            },
            {
              id: 2 # Not greater than 100 as specified in spec
            }
          ],
          not_required_by_spec: [1, 2, 3, 4]
        }
      }
    ]
  }
)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tdouce/xpect. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Xpect project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tdouce/xpect/blob/master/CODE_OF_CONDUCT.md).

## TODOs
* Fix paths in tests or provide a better way to communicate where failure happended
* Add unit tests for
  * Keys and arrays
  * Every
  * Type
    * Then remove A LOT of tests in spect_spec.rb
