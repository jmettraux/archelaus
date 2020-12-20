
module Archelaus

  class Point

    attr_accessor :dks
    attr_accessor :sx, :sy
    attr_accessor :waterway

    #attr_accessor :el, :elev
    #point.elev = point.ele ? (point.ele * 100).to_i : -100
    #point.el = point.ele ? (point.ele / 10).round : -1
    def el; @el ||= (self.ele ? (self.ele / 10).round : -1); end

    def sxsy; [ @sx, @sy ]; end
    def sx_sy; "#{@sx} #{@sy}"; end

    def to_data_ll

      "#{lat.to_fixed5} #{lon.to_fixed5} #{ele ? ele.to_fixed1 : 's'}"
    end

    def closest(points)

      pt = points
        .collect { |pt| [ Archelaus.compute_distance(latlon, pt.latlon), pt ] }
        .sort_by(&:first)
        .first

      pt ? pt[1] : nil
    end
  end

  class << self

    R0 = 100.0 / 2
    R1 = R0 / Math.cos((30.0).to_rad)

    DX = R0
    DY = R1 / 2

    def generate_svg(lat, lon, step, width, height, origin=:nw)

      g = compute_grid(lat, lon, step, width, height, origin)
      g.load_elevations
      g.load_features

      html = make(:html)
      head = make(html, :head)
      make(head, :title, 'archelaus')

      make(head, :style, wrapf(File.join(__dir__, 'svg.css')))

      body = make(html, :body)

      # unit is meter ;-)
      # from one hex to the next there is 100m

      #viewbox = [ 0, 0, 300 * 100, 300 * 100 ]
      #viewbox = [ 0, 0, 300 * 20, 300 * 20 ]
      #viewbox = [ 0, 0, 5000, 5000 ]
      #viewbox = [ 8925, -689, 5000, 5000 ]
      viewbox = [ 0, 0, 2000, 2000 ]

      svg = make(body, :svg,
        id: 'svg-map',
        viewBox: viewbox.collect(&:to_s).join(' '),
        preserveAspectRatio: 'xMinYMin slice',
        xmlns: 'http://www.w3.org/2000/svg',
        width: '100%', height: '100%')

      pats = make(svg, :g, id: 'patterns')

      make(pats, :path, # 100m hex
        id: 'h',
        d:
          "M 0 #{-R1}" +
          " L #{R0} #{-DY}" +
          " L #{R0} #{DY}" +
          " L 0 #{R1}" +
          " L #{-R0} #{DY}" +
          " L #{-R0} #{-DY}" +
          " L 0 #{-R1}")

      #{ a: 0.80, b: 0.70, c: 0.60 }.each do |k, v|
      { a: 0.70, b: 0.50, c: 0.30 }.each do |k, v|

        s = 6
        d = s.times
          .collect { |i|
            dy = 0.88 * DY
            #"M #{(i == 0 ? 0.87 : 0.66) * R0} #{-dy + i * R1 / s}" +
            "M #{(i == 0 ? 0.87 : v) * R0} #{-dy + i * R1 / s}" +
            " L #{R0} #{-dy + i * R1 / s}" }
          .join(' ')
        c = 'slope'

        make(
          pats, :path, class: c, id: "se#{k}", d: d)
        make(
          pats, :path, class: c, id: "sse#{k}", d: d, transform: 'rotate(60)')
        make(
          pats, :path, class: c, id: "ssw#{k}", d: d, transform: 'rotate(120)')
        make(
          pats, :path, class: c, id: "sw#{k}", d: d, transform: 'rotate(180)')
        make(
          pats, :path, class: c, id: "snw#{k}", d: d, transform: 'rotate(240)')
        make(
          pats, :path, class: c, id: "sne#{k}", d: d, transform: 'rotate(300)')
            #
            # hachures
      end

      make(pats, :path, # 1km hex
        id: 'H',
        d:
          "M 0 #{-R1 * 10}" +
          " L #{R0 * 10} #{-DY * 10}" +
          " L #{R0 * 10} #{DY * 10}" +
          " L 0 #{R1 * 10}" +
          " L #{-R0 * 10} #{DY * 10}" +
          " L #{-R0 * 10} #{-DY * 10}" +
          " L 0 #{-R1 * 10}")

      loffs =
        g[0, 0].lon < g[0, 1].lon ?
        [ 0, R0 ] :
        [ R0, 0 ]
#STDERR.puts g[0, 0].lon
#STDERR.puts p g[0, 1].lon

      #d0 = g.maxd * 0.1
      #d0 = 5.0
      d0 = 0.0
      d1 = g.maxd * 0.33
      d2 = g.maxd * 0.66
#STDERR.puts [ d0, d1, d2, '<-', g.maxd ].inspect

      g.rows.each do |row|
        row.each do |point|
#STDERR.puts point.dirs.inspect
          point.dks = point.ds
            .inject({}) { |h, (k, v)|
              kp = point.dirs[k]
              #if v > d0 && v < d1;      h[k] = :a
              if point.el > kp.el && v < d1;  h[k] = :a
              elsif v >= d1 && v < d2;        h[k] = :b
              elsif v >= d2;                  h[k] = :c
              end
              h } if point.ds
#STDERR.puts(point.dks.inspect) if point.dks && point.dks.values.include?(:c)
        end
      end

      south = nil
      east = nil

      g.rows.each do |row|

        row.each do |point|

          loff = loffs[point.y % 2]

          px = loff + point.x * 100
          py = point.y * 1.5 * R1

          east = px
          south = py

          cla = point.ele == nil ? 's' : 'g'
          make(
            svg,
            :use,
            href: '#h', class: cla, x: px, y: py, 'data-ll': point.to_data_ll)

          point.dks
            .each { |k, v| make(svg, :use, href: "#s#{k}#{v}", x: px, y: py)
              } if point.dks

          point.sx = px
          point.sy = py

          k =
            if ! point.dks
              nil
            elsif point.dks.count > 0
              't sl'
            elsif point.ds.all? { |_, v| v > 0.0 }
              't mx'
            elsif point.ds.all? { |_, v| v < 0.0 }
              't mn'
            else
              nil
            end

          make(svg, :text,
            point.ele.to_i.to_s,
            #point.ele.to_i.to_s + 'm',
            #point.ele.to_fixed1,
            #point.el.to_s,
            #"#{point.ele.to_i} #{point.xy.join(',')}",
            class: k, x: px, y: py + R0 / 4
              ) if k
        end
      end

      #
      # draw waterways

      sinks = g.features.waterways
        .collect { |w| make_waterway(svg, w) }
      g.features.waterways.zip(sinks)
        .each { |w, s| reconnect_waterway(svg, "ww #{w.tags['waterway']}", s) }
#exit 0

      #
      # draw kilometric hexes last (higher z)

      g.rows.each do |row|

        row.each do |point|

          loff = loffs[point.y % 2]

          px = loff + point.x * 100
          py = point.y * 1.5 * R1
#p [
#  point.x, px, point.lon, '->', px / point.lon,
#  point.x > 0 ? (px / point.lon / point.x) : nil
#    ] if loff == 0

          if (
            (point.x % 10 == 5 && point.y % 20 == 6) ||
            (point.x > 0 && point.x % 10 == 0 && point.y % 20 == 16)
          ) then
            make(svg, :use, href: '#H', x: px, y: py)
          end
        end
      end

      east = east.to_i + 50
      south = south.to_i + 50
        #
      make(body, :script, "window._east = #{east}; window._south = #{south};")

      menu = make(body, :div, { id: 'menu' })
      make(menu, :div, { class: 'latlon' }, '0.0 0.0')
      make(menu, :div, { class: 'elevation' }, '0.0m')
      nav = make(menu, :div, { class: 'nav' })

      make(nav, :span, { class: 'nw' }, 'NW')
      make(nav, :span, { class: 'ne' }, 'NE')
      make(nav, :span, { class: 'c' }, 'C')
      make(nav, :span, { class: 'sw' }, 'SW')
      make(nav, :span, { class: 'se' }, 'SE')

      make(body, :script, wrapf(File.join(__dir__, 'svg.js')))

      puts(html.to_s)
    end

    protected

    def make(*args); Archelaus::Gen.make(*args); end
    def wrapt(text); Archelaus::Gen.wrapt(text); end
    def wrapf(path); Archelaus::Gen.wrapf(path); end

    def make_waterway(svg, way)

      #make_path(svg, way, "ww #{way.tags['waterway']}")
      hs = way.hexes.sort_by { |h| h.ele }
      seen, d = draw_waterway_segment(hs.shift, hs, [], [])
      d = d.join(' ')

      k = "ww #{way.tags['waterway']}"

      make(svg, :path, class: k, d: d)

      seen.first
    end

    def draw_waterway_segment(hex, hexes, seen, r)

#STDERR.puts [ :hex, hex.ele ].inspect
#STDERR.puts [ :hexes, hexes.collect(&:ele) ].inspect
      seen << hex
      hex.waterway = true

      dirs = hex.dirs.values
      h1s = hexes.select { |h| dirs.include?(h) }

      h1s.each do |hh|
        r << "M #{hex.sx} #{hex.sy} L #{hh.sx} #{hh.sy}"
        hexes.delete(hh)
      end
      h1s.each do |hh|
        draw_waterway_segment(hh, hexes, seen, r) if hexes.any?
      end
      if h1s.empty? && hexes.any?
#STDERR.puts [ :hexes1, hexes.collect(&:ele) ].inspect
        h2 = hexes.shift
        h1 = h2.closest(seen)
#STDERR.puts h2.inspect
#STDERR.puts h1.inspect
        r << "M #{h1.sx} #{h1.sy} L #{h2.sx} #{h2.sy}"
        draw_waterway_segment(h2, hexes, seen, r)
      end

      [ seen, r ]
    end

    def reconnect_waterway(svg, klass, lowest_hex)

      dirs = lowest_hex.dirs.values.reverse

      if sea = dirs.find { |d| d && d.ele == nil }

        wx, wy = lowest_hex.sxsy

        bearing = Archelaus.compute_bearing(lowest_hex.latlon, sea.latlon) - 90
        dx = 50 * Math.cos(bearing.to_rad)
        dy = 50 * Math.sin(bearing.to_rad)
#rp [ :bearing, bearing.to_i, dx, dy ]

        make(
          svg, :path,
          class: klass + ' mouth',
          d: "M #{wx} #{wy} L #{wx + dx} #{wy + dy}")
      else

        dirs = dirs
          .select { |d| d && d.ele && d.ele < lowest_hex.ele }
          .sort_by(&:ele)
#rp [ :nos, dirs ]
        h =
          dirs.select { |d| d.waterway }.first# ||
          #dirs.first
        make(
          svg, :path,
          class: klass + ' conn', d: "M #{lowest_hex.sx_sy} L #{h.sx_sy}") if h
      end
    end

    def rp(*args)
      if args.count == 1; STDERR.puts(args.first.inspect);
      else; STDERR.puts(args.inspect); end
    end
  end
end

