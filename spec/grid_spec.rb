
#
# Specifying archelaus
#
# Thu Dec 10 20:26:45 JST 2020
#

require 'spec_helper'


describe Archelaus do

  describe '.compute_grid' do

    it 'starts with a NW origin by default' do

      g = Archelaus.compute_grid(54.41849, -0.88931, 100, 300, 300)

      expect(g.height).to eq(300)
      expect(g.width).to eq(300)
      expect(g.rows.all? { |r| r.length == 300 }).to eq(true)

#puts g[0][0].to_point_s # NW
#puts g[-1][-1].to_point_s # SE
#puts g[-1][0].to_point_s # SW
#puts g[0][-1].to_point_s # NE
      expect(g[0][0]).to   lleq([ 54.41849, -0.88931 ])  # NW
      expect(g[-1][-1]).to lleq([ 54.18587, -0.42952 ])  # SE
      expect(g[-1][0]).to  lleq([ 54.18587, -0.88854 ])  # SW
      expect(g[0][-1]).to  lleq([ 54.41848, -0.42769 ])  # NE

      expect(g[0][0].xy).to eq([ 0, 0 ])
      expect(g[-1][-1].xy).to eq([ 299, 299 ])
    end

    it 'accepts a NW origin' do

      g = Archelaus.compute_grid(54.41849, -0.88931, 100, 300, 300, :nw)

      expect(g.height).to eq(300)
      expect(g.width).to eq(300)
      expect(g.rows.all? { |r| r.length == 300 }).to eq(true)

#puts g[0][0].to_point_s # NW
#puts g[-1][-1].to_point_s # SE
#puts g[-1][0].to_point_s # SW
#puts g[0][-1].to_point_s # NE
      expect(g[0][0]).to   lleq([ 54.41849, -0.88931 ])  # NW
      expect(g[-1][-1]).to lleq([ 54.18587, -0.42952 ])  # SE
      expect(g[-1][0]).to  lleq([ 54.18587, -0.88854 ])  # SW
      expect(g[0][-1]).to  lleq([ 54.41848, -0.42769 ])  # NE

      expect(g[0][0].xy).to eq([ 0, 0 ])
      expect(g[-1][-1].xy).to eq([ 299, 299 ])
    end

    it 'accepts a NE origin' do

      g = Archelaus.compute_grid(54.41849, -0.88931, 100, 300, 300, :ne)

      expect(g.height).to eq(300)
      expect(g.width).to eq(300)
      expect(g.rows.all? { |r| r.length == 300 }).to eq(true)

#puts g[0][0].to_point_s # NW
#puts g[-1][-1].to_point_s # SE
#puts g[-1][0].to_point_s # SW
#puts g[0][-1].to_point_s # NE
      expect(g[0][0]).to   lleq([ 54.41848, -1.35092 ])  # NW
      expect(g[-1][-1]).to lleq([ 54.18587, -0.88854 ])  # SE
      expect(g[-1][0]).to  lleq([ 54.18587, -1.34755 ])  # SW
      expect(g[0][-1]).to  lleq([ 54.41849, -0.88931 ])  # NE

      expect(g[0][0].xy).to eq([ 0, 0 ])
      expect(g[-1][-1].xy).to eq([ 299, 299 ])
    end

    it 'accepts a SW origin' do

      g = Archelaus.compute_grid(54.18587, -0.88854, 100, 300, 300, :sw)

#puts g[0][0].to_point_s # NW
#puts g[-1][-1].to_point_s # SE
#puts g[-1][0].to_point_s # SW
#puts g[0][-1].to_point_s # NE
      expect(g[0][0]).to   lleq([ 54.41848, -0.88931 ])  # NW
      expect(g[-1][-1]).to lleq([ 54.18586, -0.42952 ])  # SE
      expect(g[-1][0]).to  lleq([ 54.18587, -0.88854 ])  # SW
      expect(g[0][-1]).to  lleq([ 54.41847, -0.42769 ])  # NE

      expect(g[0][0].xy).to eq([ 0, 0 ])
      expect(g[-1][-1].xy).to eq([ 299, 299 ])
    end

    it 'accepts a SE origin' do

      g = Archelaus.compute_grid(54.18587, -0.42952, 100, 300, 300, :se)

#puts g[0][0].to_point_s # NW
#puts g[-1][-1].to_point_s # SE
#puts g[-1][0].to_point_s # SW
#puts g[0][-1].to_point_s # NE
      expect(g[0][0]).to   lleq([ 54.41847, -0.89036 ])  # NW
      expect(g[-1][-1]).to lleq([ 54.18587, -0.42952 ])  # SE
      expect(g[-1][0]).to  lleq([ 54.18586, -0.88853 ])  # SW
      expect(g[0][-1]).to  lleq([ 54.41848, -0.42875 ])  # NE

      expect(g[0][0].xy).to eq([ 0, 0 ])
      expect(g[-1][-1].xy).to eq([ 299, 299 ])
    end
  end
end

describe Archelaus::Grid do

  before :all do

    @grid = Archelaus.compute_grid(54.18587, -0.42952, 100, 100, 100, :se)
  end

  describe :[] do

    it 'accepts (y)' do

      expect(@grid[1]).to eq(@grid.rows[1])
    end

    it 'accepts (x, y)' do

      expect(@grid[1, 2]).to eq(@grid.rows[2][1])
    end

    it 'accepts (lat, lon)' do

p @grid[49, 51]
      expect(@grid[54.223211, -0.506348]).to eq(@grid[49, 51])
    end
  end
end

