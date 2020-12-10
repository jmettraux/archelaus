
#
# Specifying archelaus
#
# Thu Dec 10 20:25:39 JST 2020
#

require 'pp'
require 'ostruct'

require 'archelaus'


module Helpers
end # Helpers

RSpec.configure do |c|

  c.alias_example_to(:they)
  c.alias_example_to(:so)
  c.include(Helpers)
end

RSpec::Matchers.define :peq do |expected|

  match do |actual|

    actual.collect(&:to_fixed5) == expected.collect(&:to_fixed5)
  end

  failure_message do |actual|

    "expected #{expected.inspect} but got #{actual.inspect}"
  end
end
