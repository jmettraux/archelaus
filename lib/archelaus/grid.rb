
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

    def w; tget(row, @x - 1); end
    def e; tget(row, @x + 1); end

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

    def dirs
      @dirs ||= {
        e: self.e, se: self.se, sw: self.sw,
        w: self.w, nw: self.nw, ne: self.ne }
    end

    def towards_higher(point)

      b = Archelaus.compute_bearing(self.latlon, point.latlon)

      [ b, b - 60, b + 60 ].each do |b1|
        pt = towards_bearing(b1)
        return pt if pt && pt.ele > self.ele && pt.ele < point.ele
      end

#rp [ :fail, self.xye ]
      nil
    end

    def towards(point)

      return point if dirs.values.include?(point)

      b = Archelaus.compute_bearing(self.latlon, point.latlon)
      pt = towards_bearing(b)

      return pt if pt

      towards_bearing(b + (b % 60) < 30 ? -60 : 60)
    end

    def towards_bearing(b)

      while b < 0; b = b + 360; end
      while b > 360; b = b - 360; end

      case b
      when 0...60 then ne
      when 60...120 then e
      when 120...180 then se
      when 180...240 then sw
      when 240...300 then w
      else nw; end
    end

    protected

    def tget(a, i); i < 0 ? nil : a[i]; end
    def t3(a, x); [ tget(a, x - 1), tget(a, x), tget(a, x + 1) ]; end

    def adj(dir)

      overy = @grid.rows.count + 2

      p0, p1, p2 =
        dir == :nw || dir == :ne ?
        t3(@grid.rows[@y == 0 ? overy : @y - 1] || [], @x) :
        t3(@grid.rows[@y + 1] || [], @x)
#puts "---"
#p dir
#p [ :X, self ]
#p [ 0, p0, :d, p0 ? (self.lon - p0.lon) : nil ]
#p [ 1, p1, :d, p1 ? (self.lon - p1.lon) : nil ]
#p [ 2, p2, :d, p2 ? (self.lon - p2.lon) : nil ]
#p p1 ? [ self.lon, p1.lon ] : :nop1
#p p1 ? self.lon < p1.lon : :nop1

      return nil unless p1

      if self.lon < p1.lon
        dir == :nw || dir == :sw ? p0 : p1
      else
        dir == :nw || dir == :sw ? p1 : p2
      end
    end
  end

  class Grid

    attr_reader :origin, :rows
    attr_reader :origin_corner

    def initialize(origin, rows)

      @origin_corner = rows[0][0]

      rows.reverse! if rows[0][0].lat < rows[-1][0].lat
      rows.each { |r| r.reverse! } if rows[0][0].lon > rows[0][-1].lon

      rows.each_with_index { |row, y|
        row.each_with_index { |point, x|
          point.grid = self
          point.xy = [ x, y ] } }

      @origin = origin
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

    # For testing purposes.
    #
    def truncate!(lx, ly)

      @rows = @rows[0, ly].collect { |row| row[0, lx] }

      self
    end

    def each_point(&block)

      @rows.each { |row| row.each(&block) }

      self
    end

    def points

      @rows.inject([]) { |a, row| a.concat(row) }
    end

    def corners

      { ne: @rows[0][-1], se: @rows[-1][-1], sw: @rows[-1][0], nw: @rows[0][0] }
    end

    # The corners used by the Overpass API
    # https://dev.overpass-api.de/overpass-doc/en/full_data/bbox.html
    #
    def swne

      sw = @rows[-1][0]
      ne = @rows[0][-1]

      [ sw.lat, sw.lon, ne.lat, ne.lon ]
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
        origin,
        compute_line(-1, lat, lon, step, col_angles, height)
          .each_with_index
          .collect { |p0, y|
            compute_line(y, p0.lat, p0.lon, step, row_angles, width) })
    end
  end
end


# 300 by 300
# 30km by 30km

