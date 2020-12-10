
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

class Array

  def peq(other)

    #return false unless other.is_a?(Array)
    #return false unless self.length == 2 && other.length == 2
    #return false unless self.all? { |e| e.is_a?(Float) }
    #return false unless other.all? { |e| e.is_a?(Float) }
    #other.collect(&:to_fixed5) == self.collect(&:to_fixed5)
      #
    other.to_point_s == self.to_point_s
  end
end

RSpec::Matchers.define :peq do |expected|

  match do |actual|

    actual.peq(expected)
  end

  failure_message do |actual|

    "expected #{expected.to_point_s}\n" +
    " but got #{actual.to_point_s}"
  end
end

#RSpec::Matchers.define :ceq do |expected|
#
#  match do |actual|
#
#    @actual =
#      if (actual[0][0].is_a?(Array))
#        [ actual[0][0],    # NW
#          actual[-1][-1],  # SE
#          actual[-1][0],   # SW
#          actual[0][-1] ]  # NE
#      else
#        actual
#      end
#
#    @err = %w[ NW SE SW NE ]
#      .each_with_index
#      .find { |e, i| ! @actual[i].peq(expected[i]) }
#
#    @err == nil
#  end
#
#  failure_message do |actual|
#
#    corner, index = @err
#    ex = expected[index].to_point_s
#    ac = @actual[index].to_point_s
#
#    "corner #{corner} (#{index}) should be #{ex}\n" +
#    "                 but is #{ac}"
#  end
#end

