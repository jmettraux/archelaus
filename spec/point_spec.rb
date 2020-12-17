
#
# Specifying archelaus
#
# Thu Dec 17 19:12:35 JST 2020
#

require 'spec_helper'


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

  describe '#y' do

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

  it 'determines correctly the six adjacent hexes' do

    g = Archelaus
      .compute_grid(54.41845, -0.23099, 100, 300, 300, :ne)
      .truncate!(4, 4)

#puts g.to_s
#p g[1, 1]
    expect(g[1, 1].nw).to eq(g[1, 0])
    expect(g[1, 1].ne).to eq(g[2, 0])
    expect(g[1, 1].w).to eq(g[0, 1])
    expect(g[1, 1].e).to eq(g[2, 1])
    expect(g[1, 1].sw).to eq(g[1, 2])
    expect(g[1, 1].se).to eq(g[2, 2])

#p g[0, 2]
    expect(g[0, 2].nw).to eq(nil)
    expect(g[0, 2].ne).to eq(g[0, 1])
    expect(g[0, 2].w).to eq(nil)
    expect(g[0, 2].e).to eq(g[1, 2])
    expect(g[0, 2].sw).to eq(nil)
    expect(g[0, 2].se).to eq(g[0, 3])
  end
end
