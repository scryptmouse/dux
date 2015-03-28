# Dux

A lazy duck-type matching gem that is particularly designed for use in case statements.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dux'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dux

## Usage

Usage is straightforward out of the box:

```ruby
case foo
when Dux[:bar] then foo.bar
when Dux[:baz] then foo.baz
when Dux[:quux] then foo.quux
end
```

It also has some methods for matching against a strict interface:

```ruby
case foo
when Dux.all(:bar, :baz) then foo.bar && foo.baz
when Dux.any(:quux, :bloop) then foo.try(:quux) || foo.try(:bloop)
end
```

### Core Extensions

There are a few core extensions available that can be manually enabled.

#### String / Symbol

Strings and symbols can have a `duckify` method added that operates the same
way as `Dux.[]`:

```ruby
Dux.extend_strings_and_symbols!

# Or, if you only want to touch one class:
# Dux.extend_strings!
# Dux.extend_symbols!

case foo
when "bar".duckify then foo.bar
when :baz.duckify then foo.baz
end
```

#### Array

There is also the ability to _duckify_ an array of strings or symbols for
interface matching:

```ruby
Dux.add_flock_methods!

case foo
when %i[bar baz].duckify then foo.bar && foo.baz
when %i[quux bloop].duckify(type: :any) then foo.try(:quux) || foo.try(:bloop)
end
```

#### Shorthand

There is an experimental option that uses unary `~` as an alias for `#duckify`.

`Array#~`, `String#~`, and `Symbol#~` are presently not used by Ruby core, but
other gems might define them.

```ruby
# Enable per class:
Dux.array_shorthand!
Dux.string_shorthand!
Dux.symbol_shorthand!

case foo
when ~%i[bar baz] then foo.bar && foo.baz
when ~:quux then foo.quux
when ~"bloop" then foo.bloop
end
```

#### All core extensions
To enable all core extensions:

```ruby
# To enable flock methods and String / Symbol #duckify

Dux.extend_all!

# To enable the above as well as the unary ~ shorthand:

Dux.extend_all! experimental: true
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/scryptmouse/dux/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
