
#
# Specifying archelaus
#
# Thu Dec 10 20:26:45 JST 2020
#

require 'spec_helper'


describe Archelaus do

  #pp Archelaus.compute_grid(52.204, 0.142, 100, 10, 5)
  describe '.compute_grid' do

    it 'starts with a NW origin by default' do

      g = Archelaus.compute_grid(52.204, 0.142, 100, 10, 5)

pp g
      expect(g.length).to eq(5)
      expect(g.all? { |r| r.length == 10 }).to eq(true)
      expect(g[0][0]).to peq([ 52.204, 0.142 ])
      expect(g[-1][-1]).to peq([ 52.20088, 0.15519 ])
    end

    it 'accepts a NE origin'
    it 'accepts a SW origin'
    it 'accepts a SE origin'
  end
end

