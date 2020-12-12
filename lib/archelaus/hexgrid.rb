
module Archelaus

  class Point

    attr_reader :x, :y, :lat, :lon
    attr_accessor :ele
    attr_accessor :nw, :ne, :sw, :se, :w, :e

    def initialize(x, y, lat, lon)

      @x = x
      @y = y
      @lat = lat
      @lon = lon
    end

    def [](i)

      case i
      when 0 then lat
      when 1 then lon
      else nil
      end
    end

    def to_point_s

      "#{lat.to_fixed5} #{lon.to_fixed5}"
    end
  end

  class << self

    def compute_line(y, lat, lon, step, bearing, count)

      lat1, lon1 = lat, lon
      bearings = Array(bearing)

      [ Archelaus::Point.new(0, y, lat, lon) ] +
      (count - 1).times
        .collect { |x|
          lat1, lon1 =
            compute_point(lat1, lon1, bearings[x % bearings.length], step)
          Archelaus::Point.new(x + 1, y, lat1, lon1) }
    end

    def compute_grid(lat, lon, step, width, height, origin=:nw)

      col_angles, row_angles =
        case origin
        when :ne then  [ [ 150.0, 210.0 ],                  90.0 + 180.0 ]
        when :sw then  [ [ 150.0 + 180.0, 210.0 + 180.0 ],  90.0 ]
        when :se then  [ [ 210.0 + 180.0, 150.0 + 180.0 ],  90.0 + 180.0 ]
        else           [ [ 150.0, 210.0 ],                  90.0 ] # nw
        end

      g = compute_line(-1, lat, lon, step, col_angles, height)
        .each_with_index
        .collect { |p0, y|
          compute_line(y, p0.lat, p0.lon, step, row_angles, width) }

#p [ g[0][0], g[-1][0] ]
      g.reverse! if g[0][0][0] < g[-1][0][0]
#p [ g[0][0], g[0][-1] ]
      g.each { |r| r.reverse! } if g[0][0][1] > g[0][-1][1]

      g
    end
  end
end


# 300 by 300
# 30km by 30km

