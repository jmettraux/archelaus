
#
# Specifying archelaus
#
# Thu Dec 10 20:26:45 JST 2020
#

require 'spec_helper'


describe Archelaus do

  describe '.compute_grid' do

    it 'starts with a NW origin by default' do

      g = Archelaus.compute_grid(54.41849, -0.88931, 100, 300, 300, :ne)

      expect(g.length).to eq(300)
      expect(g.all? { |r| r.length == 300 }).to eq(true)

#puts g[0][0].to_point_s # NW
#puts g[-1][-1].to_point_s # SE
#puts g[-1][0].to_point_s # SW
#puts g[0][-1].to_point_s # NE
      expect(g[0][0]).to   peq([ 54.41848, -1.35092 ])  # NW
      expect(g[-1][-1]).to peq([ 54.18587, -0.88854 ])  # SE
      expect(g[-1][0]).to  peq([ 54.18587, -1.34755 ])  # SW
      expect(g[0][-1]).to  peq([ 54.41849, -0.88931 ])  # NE
    end

    it 'accepts a NE origin' do

      g = Archelaus.compute_grid(54.4185, -0.4277, 100, 300, 300, :ne)

puts g[0][0].to_point_s # NW
puts g[-1][-1].to_point_s # SE
puts g[-1][0].to_point_s # SW
puts g[0][-1].to_point_s # NE

      expect(g[0][0]).to peq([ 54.41850, -0.88932 ])
      expect(g[-1][-1]).to peq([ 54.18589, -0.42693 ])
    end

    it 'accepts a SW origin' do

      g = Archelaus.compute_grid(54.18589, -0.88594, 100, 300, 300, :sw)

puts g[0][0].to_point_s # NW
puts g[-1][-1].to_point_s # SE
puts g[-1][0].to_point_s # SW
puts g[0][-1].to_point_s # NE

      expect(g[0][0]).to peq([ 54.41850, -0.88671 ])
      expect(g[-1][-1]).to peq([ 54.18589, -0.42692 ])
    end

    it 'accepts a SE origin'
  end
end

