
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

class Archelaus::Point

  def lleq(latlon)

    "#{latlon[0].to_fixed5} #{latlon[1].to_fixed5}" == to_point_s
  end
end

RSpec::Matchers.define :lleq do |expected|

  match do |actual|

    actual.lleq(expected)
  end

  failure_message do |actual|

    @e = Archelaus::Point.new(-1, -1, *expected)

    "expected #{@e.to_point_s}\n" +
    " but got #{actual.to_point_s}"
  end
end

