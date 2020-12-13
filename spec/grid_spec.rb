
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

    @grid = Archelaus.compute_grid(54.18587, -0.42952, 100, 10, 10, :se)
  end

  describe '#[]' do

    it 'accepts (y)' do

      expect(@grid[1]).to eq(@grid.rows[1])
    end

    it 'accepts (y) (out)' do

      expect(@grid[99]).to eq(nil)
    end

    it 'accepts (x, y)' do

      expect(@grid[1, 2]).to eq(@grid.rows[2][1])
      expect(@grid[5, 6]).to eq(@grid.rows[6][5])
    end

    it 'accepts (x, y) (out)' do

      expect(@grid[99, 99]).to eq(nil)
      expect(@grid[99, 1]).to eq(nil)
    end

    it 'accepts (lat, lon)' do

      expect(@grid[54.188203, -0.43489]).to eq(@grid[5, 6])
    end

    it 'accepts (lat, lon) (out)' do

      expect(@grid[100.188203, -0.43489]).to eq(nil)
      expect(@grid[54.188203, -100.0]).to eq(nil)
    end
  end

  describe '#rows' do

    it 'returns the row array' do

      r = @grid.rows

      expect(r.class).to eq(Array)
      expect(r.count).to eq(10)
      expect(r.first.count).to eq(10)
      expect(r[0].collect(&:class).uniq).to eq([ Archelaus::Point ])
      expect(r[-1].collect(&:class).uniq).to eq([ Archelaus::Point ])
    end
  end
end

describe Archelaus::Point do

  before :all do

    @grid = Archelaus.compute_grid(54.18587, -0.42952, 100, 10, 10, :se)

    @point = @grid[4, 6]
  end

  describe '#x' do

    it "returns the point's x" do

      expect(@point.x).to eq(4)
    end
  end

  describe '#x' do

    it "returns the point's y" do

      expect(@point.y).to eq(6)
    end
  end

  describe '#xy' do

    it "returns the point's x and y" do

      expect(@point.xy).to eq([ 4, 6 ])
    end
  end

  describe '#row' do

    it 'returns the row to which the point belongs' do

      expect(@point.row).to eq(@grid.rows[6])
      expect(@point.row.class).to eq(Array)
      expect(@point.row).to eq(@point.grid.rows[6])
      expect(@point.row[4]).to eq(@point)
      expect(@point.row[4].class).to eq(Archelaus::Point)
    end
  end

  describe '#nw' do

    it 'returns the NW adjacent point' do

      expect(@point.nw).to eq(@grid[4, 5])

      expect(@grid[3, 6].nw).to eq(@grid[3, 5])
      expect(@grid[3, 7].nw).to eq(@grid[2, 6])
    end
  end

  describe '#ne' do

    it 'returns the NE adjacent point' do

      expect(@point.ne).to eq(@grid[5, 5])

      expect(@grid[3, 6].ne).to eq(@grid[4, 5])
      expect(@grid[3, 7].ne).to eq(@grid[3, 6])
    end
  end

  describe '#sw' do

    it 'returns the SW adjacent point' do

      expect(@point.sw).to eq(@grid[4, 7])

      expect(@grid[3, 6].sw).to eq(@grid[3, 7])
      expect(@grid[3, 7].sw).to eq(@grid[2, 8])
    end
  end

  describe '#se' do

    it 'returns the SE adjacent point' do

#puts @grid.to_s
      expect(@point.se).to eq(@grid[5, 7])

      expect(@grid[3, 6].se).to eq(@grid[4, 7])
      expect(@grid[3, 7].se).to eq(@grid[3, 8])
    end
  end

  describe '#w' do

    it 'returns the W adjacent point' do

      expect(@point.w).to eq(@grid[4 - 1, 6])
    end
  end

  describe '#e' do

    it 'returns the E adjacent point' do

      expect(@point.e).to eq(@grid[4 + 1, 6])
    end
  end
end

