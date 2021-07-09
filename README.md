# Middlegem

[![Build Status](https://travis-ci.com/jacoblockard99/middlegem.svg?branch=master)](https://travis-ci.com/jacoblockard99/middlegem)

[![Inline docs](http://inch-ci.org/github/jacoblockard99/middlegem.svg?branch=master)](http://inch-ci.org/github/jacoblockard99/middlegem)

[![Maintainability](https://api.codeclimate.com/v1/badges/b43ed85211cb562678bb/maintainability)](https://codeclimate.com/github/jacoblockard99/middlegem/maintainability)

[![Test Coverage](https://api.codeclimate.com/v1/badges/b43ed85211cb562678bb/test_coverage)](https://codeclimate.com/github/jacoblockard99/middlegem/test_coverage)

`middlegem` is a Ruby gem that provides one-way middleware chain functionality. It aims to be simple and reliable. It might be a good fit for you if:
  - **You want simplicity and reliability.**
  - **You don't need two-way middleware.** `middlegem` does not allow processing both the "request" and the "response", for example. For that kind of functionality, I would recommend checking out [ruby-middleware](https://github.com/Ibsciss/ruby-middleware).
  - **You want to explicitly define the order of your middlwares.** `middlegem` encourages you to explicitly define your middlewares and the order they should run.

## Links

- [API Docs](https://rdoc.info/github/jacoblockard99/middlegem)
- [CHANGELOG.md](CHANGELOG.md)
- [Releases](https://github.com/jacoblockard99/middlegem/releases)

## Installation

`middlegem` is a Ruby gem. If you use Bundler, you may install it by adding it to your `Gemfile`, like so:

```ruby
gem 'middlegem'
```

And then execute:

    $ bundle install

Or you may install it manually with:

    $ gem install middlegem

`middlegem` has zero dependencies and requires very little setup to get started!

## Key Concepts

`middlegem` is broken into three key parts: middlewares, middleware definitions, and middleware stacks.

**Middlewares** are the heart and soul of the gem. In essence, a middleware is a single transforming function that accepts input and produces output. In `middlegem`, any object that responds to the `call` method can be a middleware. By convention, however, middleware classes derive from `Middlegem::Middleware`.

Middlewares in `middlegem` are designed to operate on *argument lists*. This has two consequences:
  1. A middleware's `call` method should simply accept the arguments it expects to transform—no need to accept and "arguments array" and try to parse it!
  2. The `call` method **must** return an array. Because it is transforming an argument list, it must also return an argument list, i.e. an array.

While you can certainly use `middlegem` with a single input, always remember to return an array in your middleware `call` methods.

**Midleware definitions** are a key difference in `middlegem` from other middleware gems. They strive to solve a common problem with middlewares. Imagine, for example, that you have two middlewares: one that converts an input string to an integer, and another that multiplies that number by 10. Obviously, the conversion middleware must run first, or an error will occur. With a simple example like this, it is trivial to simply insert the middlewares in the right place at the right time. But as you begin adding more middlewares and—worse—begin allowing *custom* middlewares to be defined, things quickly become unmanageable! It becomes impossible to know exactly where a given middleware should be inserted in a middleware stack.

This is where middleware definitions come in. A middleware definition is essentially an object that determines 1) what middlewares are permitted in a middleware stack, and 2) in what order those middlewares should be run. Any object that implements a `defined?` method and a `sort` method can be avalid middleware definition, though by convention middleware definitions derive from `Middlegem::Definition`. The only middleware definition that currently ships with `middlegem` is `Middlegem::ArrayDefinition`, which allows you to define an ordered list of permitted middleware classes.

Finally, **middleware stacks**, represented by `Middlegem::Stack`, are chains of middlewares. Every `Middlegem::Stack` has a single middleware definition that determines how to run its middlewares. Note that `Middlegem::Stack` has no fancy methods for inserting middlewares at specific locations—it relies on Ruby's built-in methods. Instead, it allows ordering to be determined by the middleware definition.

## Usage

### Basic Usage

The easiest way to define middlewares is to create a class with a `call` method that optionally extends `Middlegem::Middleware`. In this example and the following ones, assume that these middlewares are defined:

```ruby
class ParenthesesMiddleware << Middlegem::Middleware
  def call(input)
    ["(#{input})"]
  end
end

class BracketsMiddleware << Middlegem::Middleware
  def call(input)
    ["[#{input}]"]
  end
end

class BracesMiddleware << Middlegem::Middleware
  def call(input)
    ["{#{input}}"]
  end
end

class MultiplierMiddleware << Middlegem::Middleware
  attr_accessor :multiplier

  def initialize(multiplier)
    @multiplier = multiplier
  end

  def call(num)
    [num * multiplier]
  end
end
```

Now you'll need to _define_ your middleware. If you're using Rails, initializers are usually a good place to do this. The easiest way to create a middleware definition is using `Middlegem::ArrayDefinition`, which allows you to specify an array of middleware classes. For example:

```ruby
DEFINITION = Middlegem::ArrayDefinition.new([
  MultiplierMiddleware,
  ParenthesesMiddleware,
  BracketsMiddleware,
  BracesMiddleware
])
```

Notice that the `MultiplierMiddleware` is at the top, because it must be given a number, and the others are arranged in "mathematical" order. Now, we can create a middleware stack with our definition.

```ruby
stack = Middlegem::Stack.new(DEFINITION)
```

And add some middlewares, however you like:

```ruby
stack.middlewares = [BracketsMiddleware]
stack.middlewares += [MultiplierMiddleware, BracesMiddleware]
stack.middlewares << ParenthesesMiddleware
```

Finally, we can call the stack with a number:

```ruby
stack.call(10) # => ["{[(100)]}"]
```

Notice how the number is first multiplied, then given parentheses, then given brackets, then given braces, exactly as specified in the middleware definition.

### Tie Resolvers

You may have noticed a problem here. What if multiple middleware instances of the same type are added to a stack. How will it know which to call? Take this code, for example, where procs are used as middleware:

```ruby
DEFINITION = Middlegem::ArrayDefinition.new([Proc])

to_int = proc { |s| Integer(s) }
square = proc { |n| n*n }

stack = Middlegem::Stack.new(DEFINITION, middlewares: [
  square,
  to_int
])
```

If `stack.call('5')` were run right now, the program would try to square `'5'`, *then* convert it to an integer. Moreover, there is no way to specify which should come first—they are both procs, after all. For this reason, it is recommended that you keep all your middlewares in separate classes, so they can be defined easily. There are two potential solutions, however.

First, `ArrayDefinition.new` accepts an optional "tie resolver" that will be called in such cases. For example, let's say we have this middleware:

```ruby
class AppendMiddleware
  attr_accessor :appended

  def initialize(appended)
    @appended = appended
  end

  def call(input)
    [input + appended]
  end
end
```

Obviously, the order of even individual `AppendMiddleware`s matters. "TAB" is a very differnt word from "BAT"! Imagining that we want the letters to be alphabetized, here is one potential solution:

```ruby
DEFINITION = Middlegem::ArrayDefinition.new([AppendMiddleware], resolver: ->(ties) {
  if ties.count > 1 && ties.first.is_a? AppendMiddleware
    return ties.sort_by(&:appended)
  end
  ties
})

stack = Middlegem::Stack.new(DEFINITION, middlewares: [
  AppendMiddleware.new('B'),
  AppendMiddleware.new('A'),
  AppendMiddleware.new('C'),
  AppendMiddleware.new('E'),
  AppendMiddleware.new('D')
end

stack.call('') # => ['ABCDE']
```

As you can see, the resolver passed to `ArrayDefinition.new` will be called with an array of middleware whenever multiple middleware with the same class are encountered. The resolver is then expected to sort and return the array appropriately. In this case, we simply check whether the tied middlewares are `AppendMiddleware`s and sort them by their `appended` attribute if so.

While this works, the limitations quickly become obvious. Mainly, it requires a bunch of branching `else/if` or `case/when` structures in the resolver since that one resolver is called for all ties. While it may work for very simple use cases (such as preventing multiple instances of the same middleware at all), it is not feasible for anything more complicated.

For more complicated scenarios, it is instead recommended that you create your own implementation of `Middlegem::Definition` that allows ordering the middlewares in some other way. Perhaps you could set "priorities" on the middlewares, or organize them into "groups"—the possibilities with this method are limitless!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jacoblockard99/middlegem.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
