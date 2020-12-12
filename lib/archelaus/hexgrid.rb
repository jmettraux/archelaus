
module Archelaus

  class Point

    attr_reader :lat, :lon
    attr_accessor :x, :y, :ele
    attr_accessor :nw, :ne, :sw, :se, :w, :e

    def initialize(lat, lon)

      @lat = lat
      @lon = lon
    end

    def xy=(xy); @x, @y = xy; end
    def xy; [ x, y ]; end

    def [](i)

      case i
      when 0 then lat
      when 1 then lon
      else nil
      end
    end

    def to_point_s; "#{lat.to_fixed5} #{lon.to_fixed5}"; end
  end

  class Grid

    attr_reader :rows

    def initialize(rows)

      rows.reverse! if rows[0][0].lat < rows[-1][0].lat
      rows.each { |r| r.reverse! } if rows[0][0].lon > rows[0][-1].lon

      rows.each_with_index { |r, y|
        r.each_with_index { |p, x|
          p.xy = [ x, y ] } }

      @rows = rows
    end

    def [](x, y=nil)

      case y
      when nil then @rows[x] # ;-)
      when Integer then @rows[y][x]
      when Float then locate(x, y)
      else fail ArgumentError.new("cannot lookup #{x.inspect} #{y.inspect}")
      end
    end

    def height; rows.length; end
    def width; rows.first.length; end
  end

  class << self

    def compute_line(y, lat, lon, step, bearing, count)

      lat1, lon1 = lat, lon
      bearings = Array(bearing)

      [ Archelaus::Point.new(lat, lon) ] +
      (count - 1).times
        .collect { |x|
          lat1, lon1 =
            compute_point(lat1, lon1, bearings[x % bearings.length], step)
          Archelaus::Point.new(lat1, lon1) }
    end

    def compute_grid(lat, lon, step, width, height, origin=:nw)

      col_angles, row_angles =
        case origin
        when :ne then  [ [ 150.0, 210.0 ],                  90.0 + 180.0 ]
        when :sw then  [ [ 150.0 + 180.0, 210.0 + 180.0 ],  90.0 ]
        when :se then  [ [ 210.0 + 180.0, 150.0 + 180.0 ],  90.0 + 180.0 ]
        else           [ [ 150.0, 210.0 ],                  90.0 ] # nw
        end

      Archelaus::Grid.new(
        compute_line(-1, lat, lon, step, col_angles, height)
          .each_with_index
          .collect { |p0, y|
            compute_line(y, p0.lat, p0.lon, step, row_angles, width) })
    end
  end
end


# 300 by 300
# 30km by 30km

