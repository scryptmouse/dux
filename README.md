# Dux [![Build Status](https://travis-ci.org/scryptmouse/dux.svg?branch=master)](https://travis-ci.org/scryptmouse/dux)

A swiss-army knife of duck-type and utility objects without monkey-patching.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'dux'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install dux

## Dux[] / Predicates

`Dux[]` can be used for creating predicate matchers for case equality.
It will check if whatever it is compared against can `respond_to?` the
symbol it's provided with.

Usage is straightforward:

```ruby
case foo
when Dux[:bar]
  foo.bar
when Dux[:baz]
  foo.baz
when Dux[:quux]
  foo.quux
else
  raise TypeError, "Dunno what do to do with #{foo.inspect}"
end
```

Because it uses lambdas under the hood, it can also be used
as an enumerable predicate:

```ruby
list_of_objects_that_should_conform.all?(&Dux[:some_method])
```

That's not the intended usage, but it works.

### Inheritance / Inclusion / Extension

There are also predicates for testing class structure:

```ruby
class SomeClass < SomeParentClass
  extend SomeDSLMethods
  include SomeHelpers
  prepend SomeOverrides
end

Dux.inherits(SomeParentClass) === SomeClass # => true
Dux.inherits(SomeHelpers) === SomeClass # => true
Dux.inherits(SomeOverrides) === SomeClass # => true

# If you want to use Module#<= in the predicate, use include_self: true
Dux.inherits(SomeClass, include_self: true) === SomeClass # => true

# Testing for module extension is different.
Dux.extends(SomeDSLMethods) === SomeClass # => true
```

`Dux.inherits` is aliased to `Dux.prepends` and `Dux.includes`
for semantic clarity, but it does not currently check
if a module was included or prepended.

### Interfaces

There are also some methods for matching against a strict / flexible interface:

```ruby
case foo
when Dux.all(:bar, :baz)
  foo.bar && foo.baz
when Dux.any(:quux, :bloop)
  Dux.attempt(foo, :quux) || Dux.attempt(foo, :bloop)
end
```

### YARD Types

If you have a condition more easily expressed in [YARD types](http://yardoc.org/types),
you can do something like the following:

```ruby
case some_overloaded_arg
when Dux.yard('(Symbol, Symbol)')
  # Do something with a tuple of two symbols
when Dux.yard('{ Symbol => <Symbol> }')
  # Do something with a symbol-keyed hash with
  # values that are an array of symbols
when Dux.yard('<SomeClass>')
  # Do something with an array of `SomeClass` members
end
```

Performance of the underlying gem is not thoroughly tested,
but it should work just fine for non-intensive use cases.

## Dux.comparable

Simplifies creating comparable objects when just want
to compare on a couple of attributes defined on objects.

```ruby
class Person < Struct.new(:name)
  include Dux.comparable :name
end

alice = Person.new 'Alice'
bob   = Person.new 'Bob'
carol = Person.new 'Carol'

[bob, carol, alice].sort == [alice, bob, carol]

# You can also sort descending:

Person.include Dux.comparable :name, sort_order: :desc

[alice, carol, bob].sort == [carol, bob, alice]
```

You can additionally specify multiple attributes with
individual sort ordering for each attribute:

```ruby
class Person < Struct.new(:name, :salary)
  include Dux.comparable [:salary, :desc], :name
end

alice = Person.new 'Alice', 100_000
bob   = Person.new 'Bob', 75_000
carol = Person.new 'Carol', 100_000

[carol, bob, alice].sort == [alice, carol, bob]
```

## Dux.enum

Create an indifferent set of strings/symbols that can be used
to validate options.

```ruby
ROLES = Dux.enum :author, :admin, :reader

ROLES[:author] # => :author
ROLES[:nonexistent] # raises Dux::Enum::NotFound

ROLES.fetch :nonexistent do |value|
  raise YourErrorHere, "Invalid role: #{value}"
end
```

If you want a specific fallback value instead of raising an error, you can do that too

```ruby
ROLES = Dux.enum :author, :admin, :reader, default: :reader

ROLES[:nonexistent] # => :reader

# Override the fallback for a particular fetch
ROLES[:nonexistent, fallback: :author] # => :author
```

## Utilities

Small utility methods, many to replace needing ActiveSupport / monkey patching.

### Dux.attempt

`Object#try` when you don't have/want ActiveSupport.

It will attempt to execute a provided method (with optional args and block)
with `public_send`, or simply return `nil` if it doesn't respond.

```ruby
Dux.attempt(some_object, :method, *args, &block)
```

### Dux.blankish? / Dux.presentish?

`Object#blank?` & `Object#present?` when you don't have/want ActiveSupport.

Rather than being monkey patched across all `Object`s, you will need to
use `Dux` to check:

```ruby
Dux.blankish? [nil] # => true
Dux.blankish? Hash.new # => true
Dux.blankish? "\t" # => true
Dux.blankish? Float::NAN
```

### Dux.inspect_id

If you are overriding the `#inspect` method on an object and want
to keep that unique hex `object_id`, this offers a shorthand:

```ruby
def inspect
  "#<YourClassHere:#{Dux.inspect_id(self)}>"
end
```

## Monkey patches / Experimental

These will probably end up getting removed for version 1.x.

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

#### ~ Shorthand

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

## Supported Ruby Versions

* MRI 2.2+
* Rubinius 2.5+
* jruby-head / 9.0+

## Contributing

1. Fork it ( https://github.com/scryptmouse/dux/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
