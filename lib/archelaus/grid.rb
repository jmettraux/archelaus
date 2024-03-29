
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

    def dup; Point.new(@lat, @lon); end

    def id; "h_#{@x}_#{@y}"; end
    alias sid id

    def [](i)

      case i
      when 0 then @lat
      else @lon
      end
    end

    def xy=(xy); @x, @y = xy; end
    def xy; [ @x, @y ]; end

    def latlon; [ @lat, @lon ]; end

    def compute_distance(x)

      Archelaus.compute_distance(latlon, x.latlon)
    end

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
        pele = pt && (pt.ele || Archelaus::Grid::SEA_LEVEL)
        return pt if pele && (pele > self.ele) && (pele < point.ele)
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

    attr_reader :name
    attr_reader :origin, :step, :rows
    attr_reader :origin_corner

    def initialize(origin, step, rows)

      @origin_corner = rows[0][0]

      rows.reverse! if rows[0][0].lat < rows[-1][0].lat
      rows.each { |r| r.reverse! } if rows[0][0].lon > rows[0][-1].lon

      rows.each_with_index { |row, y|
        row.each_with_index { |point, x|
          point.grid = self
          point.xy = [ x, y ] } }

      @origin = origin
      @step = step
      @rows = rows
    end

    def set_name(s)

      @name = s
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

    def nw

      @rows.first.first
    end

    def _lowest_ele

      le = 99_999.0

      @rows.each do |row|
        row.each do |point|
          return nil if point.ele == nil
          le = point.ele if point.ele && point.ele < le
        end
      end

      le
    end

    def _highest_ele

      he = -99_999.0

      @rows.each do |row|
        row.each do |point|
          he = point.ele if point.ele && point.ele > he
        end
      end

      he
    end

    def lowest_ele; @lowest_ele ||= _lowest_ele; end
    def highest_ele; @highest_ele ||= _highest_ele; end

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

    def abate(lat, lon)

      hex, dis = nil, 9_9999

      rs2 = @rows.take(2)
      lonf = (rs2[0].first.lon + rs2[1].first.lon) / 2
      lonl = (rs2[0].last.lon + rs2[1].last.lon) / 2

      @rows.each do |r|
        h = r.first
        d = Archelaus.compute_distance([ h.lat, lonf ], [ lat, lon ])
        break if d > dis
        hex, dis = h, d
      end
      @rows.each do |r|
        h = r.last
        d = Archelaus.compute_distance([ h.lat, lonl ], [ lat, lon ])
        break if d > dis
        hex, dis = h, d
      end

      hex
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

    def crop(x0, y0, x1, y1)

      y0 = y0 - 1 if y0 % 2 == 1

      Grid.new(
        :nw,
        @step,
        @rows[y0..y1].collect { |row| row[x0..x1].collect(&:dup) })
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

    def way_lines(nodes)

      nodes.collect { |n| locate(n.lat, n.lon) }.uniq.compact
    end

    def way_polygon(nodes)

      Polygon.new(self, nodes).enumerate_hexes
    end
  end

  class Polygon

    def initialize(grid, nodes)

      @grid = grid
      @nodes = nodes

      @segments = []
        #
      nodes.length.times { |i|
        @segments << Segment.new(@grid, *nodes.rotate(i)[0, 2]) }
    end

    def enumerate_hexes

      return [] if ! in_grid?

      hs = @segments.collect(&:hexes).flatten(1).uniq
#$stderr.puts [ hs.length, hs.uniq.length ].inspect

      return hs if hs.length < 1

      rows = hs
        .inject({}) { |h, hex|
          (h[hex.y] ||= []) << hex
          h }
        .values
        .each { |row|
          next if row.length < 2
          row.sort_by(&:x).each_slice(2).each do |sl|
            next if sl.length != 2
            hx = sl[0]
            mx = sl[1].x
#$stderr.puts [ hx, mx ].inspect
            while hx.x < mx
              hs << hx
              hx = hx.e # go east, towards mx
            end
          end
        }

      hs.uniq
    end

    protected

    def in_grid?

      @segments.any?(&:in_grid?)
    end
  end

  class Segment

    def initialize(grid, node0, node1)

      @grid = grid
      @node0 = node0
      @node1 = node1

      @in_grid_hexes = list_in_grid_hexes
    end

    def in_grid?

      @in_grid_hexes.any?
    end

    def hexes

      @hexes ||= list_hexes
    end

    protected

    def ber_dis_step

      [ Archelaus.compute_bearing(@node0.latlon, @node1.latlon),
        Archelaus.compute_distance(@node0.latlon, @node1.latlon),
        @grid.step / 3 ]
    end

    def list_in_grid_hexes

      ber, dis, step = ber_dis_step

      a = []
      d = 0
        #
      loop do
        pt = Archelaus.compute_point(@node0.latlon, ber, d)
        hx = @grid.locate(*pt)
        a << hx if hx
        d = d + step
        break if d > dis + step
      end

      a.uniq
    end

    def list_hexes

      ber, dis, step = ber_dis_step

      a = []
      d = 0
        #
      loop do
        pt = Archelaus.compute_point(@node0.latlon, ber, d)
        hx = @grid.locate(*pt) || @grid.abate(*pt)
        a << hx if hx
        d = d + step
        break if d > dis + step
      end

      a.uniq
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
        step,
        compute_line(-1, lat, lon, step, col_angles, height)
          .each_with_index
          .collect { |p0, y|
            compute_line(y, p0.lat, p0.lon, step, row_angles, width) })
    end
  end
end


# 300 by 300
# 30km by 30km

