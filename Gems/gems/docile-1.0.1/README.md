# Docile

Definition: *Ready to accept control or instruction; submissive* [[1]]

Tired of overly complex DSL libraries and hairy meta-programming?

Let's make our Ruby DSLs more docile...

[1]: http://www.google.com/search?q=docile+definition   "Google"

[![Build Status](https://travis-ci.org/ms-ati/docile.png)](https://travis-ci.org/ms-ati/docile)
[![Dependency Status](https://gemnasium.com/ms-ati/docile.png)](https://gemnasium.com/ms-ati/docile)

## Basic Usage

Let's say that we want to make a DSL for modifying Array objects.
Wouldn't it be great if we could just treat the methods of Array as a DSL?

```ruby
with_array([]) do
  push 1
  push 2
  pop
  push 3
end
# => [1, 3]
```

No problem, just define the method `with_array` like this:
``` ruby
def with_array(arr=[], &block)
  Docile.dsl_eval(arr, &block)
end
```

Easy!

## Advanced Usage

Mutating (changing) an Array instance is fine, but what usually makes a good DSL is a [Builder Pattern][2].

For example, let's say you want a DSL to specify how you want to build a Pizza:
```ruby
@sauce_level = :extra

pizza do
  cheese
  pepperoni
  sauce @sauce_level
end
# => #<Pizza:0x00001009dc398 @cheese=true, @pepperoni=true, @bacon=false, @sauce=:extra>
```

And let's say we have a PizzaBuilder, which builds a Pizza like this:
```ruby
Pizza = Struct.new(:cheese, :pepperoni, :bacon, :sauce)

class PizzaBuilder
  def cheese(v=true); @cheese = v; end
  def pepperoni(v=true); @pepperoni = v; end
  def bacon(v=true); @bacon = v; end
  def sauce(v=nil); @sauce = v; end
  def build
    Pizza.new(!!@cheese, !!@pepperoni, !!@bacon, @sauce)
  end
end

PizzaBuilder.new.cheese.pepperoni.sauce(:extra).build
#=> #<Pizza:0x00001009dc398 @cheese=true, @pepperoni=true, @bacon=false, @sauce=:extra>
```

Then implement your DSL like this:

``` ruby
def pizza(&block)
  Docile.dsl_eval(PizzaBuilder.new, &block).build
end
```

It's just that easy! 

[2]: http://stackoverflow.com/questions/328496/when-would-you-use-the-builder-pattern  "Builder Pattern"

## Features

  1.  method lookup falls back from the DSL object to the block's context
  2.  local variable lookup falls back from the DSL object to the block's context
  3.  instance variables are from the block's context only
  4.  nested dsl evaluation

## Installation

``` bash
$ gem install docile
```

## Documentation

Documentation hosted on *rubydoc.info*: [Docile Documentation](http://rubydoc.info/gems/docile)

Or, read the code hosted on *github.com*: [Docile Code](https://github.com/ms-ati/docile)

## Status

Version 1.0 works on [all ruby versions](https://github.com/ms-ati/docile/blob/master/.travis.yml).

## Note on Patches/Pull Requests

  * Fork the project.
  * Setup your development environment with: gem install bundler; bundle install
  * Make your feature addition or bug fix.
  * Add tests for it. This is important so I don't break it in a
    future version unintentionally.
  * Commit, do not mess with rakefile, version, or history.
    (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
  * Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2012 Marc Siegel. See LICENSE for details.
