
module Archelaus

  class Point

    attr_reader :lat, :lon
    attr_reader :x, :y
    attr_accessor :grid
    attr_accessor :ele

    def initialize(lat, lon)

      @lat = lat
      @lon = lon
    end

    def id; "x#{@x}y#{@y}"; end

    def [](i)

      case i
      when 0 then @lat
      else @lon
      end
    end

    def xy=(xy); @x, @y = xy; end
    def xy; [ @x, @y ]; end

    def latlon; [ @lat, @lon ]; end

    def to_point_s; "#{lat.to_fixed5} #{lon.to_fixed5}"; end

    def row; @grid.rows[@y]; end

    def w; row[@x - 1]; end
    def e; row[@x + 1]; end

    def inspect

      "<Archelaus::Point" +
      " lat=#{@lat.inspect} lon=#{@lon.inspect}" +
      " x=#{@x.inspect} y=#{@y.inspect}" +
      " ele=#{@ele.inspect}" +
      " grid=#{@grid ? @grid.dim : @grid.inspect}" +
      ">"
    end

    def nw; @nw ||= adj(:nw); end
    def ne; @ne ||= adj(:ne); end
    def sw; @sw ||= adj(:sw); end
    def se; @se ||= adj(:se); end

    protected

    def adj(dir)

      p0, p1, p2 =
        dir == :nw || dir == :ne ?
        (@grid.rows[@y - 1] || [])[@x - 1, 3] :
        (@grid.rows[@y + 1] || [])[@x - 1, 3]
#puts "---"
#p [ :X, self ]
#p [ 0, p0, :d, self.lon - p0.lon ]
#p [ 1, p1, :d, self.lon - p1.lon ]
#p [ 2, p2, :d, self.lon - p2.lon ]

      return nil unless p1

      if self.lon <= p1.lon
        dir == :nw || dir == :sw ? p0 : p1
      else
        dir == :nw || dir == :sw ? p1 : p2
      end
    end
  end

  class Grid

    attr_reader :rows

    def initialize(rows)

      rows.reverse! if rows[0][0].lat < rows[-1][0].lat
      rows.each { |r| r.reverse! } if rows[0][0].lon > rows[0][-1].lon

      rows.each_with_index { |row, y|
        row.each_with_index { |point, x|
          point.grid = self
          point.xy = [ x, y ] } }

      @rows = rows
    end

    def [](x, y=nil)

      case y
      when nil then @rows[x] # ;-)
      when Integer then (@rows[y] || [])[x]
      when Float then locate(x, y)
      else fail ArgumentError.new("cannot lookup #{x.inspect} #{y.inspect}")
      end
    end

    def height; @rows.length; end
    def width; @rows.first.length; end
    def dim; "#{width}x#{height}"; end

    def locate(lat, lon)

      @rows.each_with_index do |row, y|

        point0 = row.first

        row1 = @rows[y + 1]; return nil unless row1

        point1 = row1.first

        d0 = (point0.lat - lat)
        d1 = (point1.lat - lat)

        next if d0.sign == d1.sign

        row = d0.abs < d1.abs ? row : row1

        row.each_with_index do |point, x|

          point1 = row[x + 1]; return nil unless point1

          d0 = (point.lon - lon)
          d1 = (point1.lon - lon)

          next if d0.sign == d1.sign

          return d0.abs < d1.abs ? point : point1
        end
      end

      nil
    end

    def to_s

      w = @rows[0][0].to_point_s.length
      as = [ '        | ', '| ' ]
      as.reverse! if @rows[0][0].lon < @rows[1][0].lon

      s = StringIO.new

      @rows.each_with_index do |row, y|
        r0 = nil
        r1 = nil
        r2 = nil
        row.each_with_index do |point, x|
          r0 = [ r0, point.to_point_s ].compact.join(' | ')
          r1 = [ r1, "%#{w}s" % "#{point.x},#{point.y}" ].compact.join(' | ')
        end
        a = as[y % 2]
        s << a + r0 + "\n"
        s << a + r1 + "\n"
        s << "\n"
      end

      s.string
    end

    def elevations

      eles = @rows.flatten.collect(&:ele).compact + [ 0.0 ]

      [ eles.min, eles.max ]
    end
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

