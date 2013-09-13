require 'simplecov'
require 'coveralls'

Coveralls.wear!

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter '/spec/'
end

require 'stub_factory'

# Methods defined by .define_helper will not work without this:
RSpec.configure do |config|
  config.include StubFactory::Helpers
end
