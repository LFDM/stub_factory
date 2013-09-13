# StubFactory
# ArrayScanner
[![Build Status](https://travis-ci.org/LFDM/stub_factory.png)](https://travis-ci.org/LFDM/stub_factory)
[![Coverage Status](https://coveralls.io/repos/LFDM/stub_factory/badge.png)](https://coveralls.io/r/LFDM/stub_factory)
[![Dependency Status](https://gemnasium.com/LFDM/stub_factory.png)](https://gemnasium.com/LFDM/stub_factory)

A blunt StubFactory that helps to test tightly coupled code, but handle with care: This is not a best practice. If you find yourself relying on this a lot, you might have to rethink your design. 

## Installation

Add this line to your application's Gemfile:

    gem 'blunt_stub_factory'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blunt_stub_factory

## Usage

```ruby
require 'stub_factory'
# beware: StubFactory resides in the stub_factory file, not as it's gemname would indicate (the name stub_factory was already taken...)

Class A
  attr_reader :test, :test2
  
  def initialize
    @test  = "a value"
    @test2 = "another value"
  end
  
  def a_method
    "original return"
  end
end
```

StubFactory provides a method to bypass the constructor of an object and set it's instance variables by force.

```ruby
a = A.new_stub(vars: { test: "overwritten" })
b = A.new

a.test 
# => "overwritten"
b.test 
# => "original value"
```

Default as well as custom templates to overwrite variables can be defined - StubFactory automatically looks for such statements
in your spec/factories folder.
```ruby
StubFactory.define_template(:a) do
  { test2 = "template value" }
end

StubFactory.define_template(:other) do
  { test2 = "custom value" }
end

# a new stub tries to look up a template by his class name by default
a = A.new_stub
a.test2
# => "template value"

# default template overwritten with custom template
b = A.new_stub(template: :custom)
b.test2
# => "custom value"

# if template is passed with a value of nil, no template will be used
c = A.new_stub(template: nil)
c.test2
# => "another value"
```

Method return values can be stubbed.
```ruby
a = A.new_stub(methods: { a_method: "overwritten method" }
b = A.new

a.a_method
# => "overwritten method"
b.a_method
# => "original return"
```

For ease of use, helper methods can be defined when they are included in your RSpec configuarion. 
Place define_helper statements in your spec/support/helpers folder.
```ruby
RSpec.configure do |config|
  config.include StubFactory::Helpers
end

StubFactory.define_helper(:a, :A) do
  { vars: { test: 1 }, methods: { a_method: 2 } }
end
# creates a method stub_a, which translates to A.new_stub(vars: { test: 1 }, methods: { a_method: 2 })

# given a defined template, the helper will automatically refer to it
StubFactory.define_template(:foo) do
  { test: 1 }
end

StubFactory.define_helper(:foo, :A) do
  { vars: { test2: 2 } }
end

a = stub_foo
a.class
# => A
a.test
# => 1
a.test2
# => 2

# all default values can be overwritten
a = stub_foo(vars: { test2: "bypassed" })
a.test2
# => "bypassed"
```
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
