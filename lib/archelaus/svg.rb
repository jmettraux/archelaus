
module Archelaus

  class Point

    attr_accessor :dks
    attr_accessor :sx, :sy
    attr_accessor :waterways

    #attr_accessor :el, :elev
    #point.elev = point.ele ? (point.ele * 100).to_i : -100
    #point.el = point.ele ? (point.ele / 10).round : -1
    def el; @el ||= (self.ele ? (self.ele / 10).round : -1); end

    def sxsy; [ @sx, @sy ]; end
    def sx_sy; "#{@sx} #{@sy}"; end

    def xye; [ xy, ele ]; end

    def to_data_ll

      "#{x},#{y}" +
      " #{lat.to_fixed5} #{lon.to_fixed5}" +
      " #{ele ? ele.to_fixed1 : 's'}"
    end

    def closest(points)

      pt = points
        .collect { |pt| [ Archelaus.compute_distance(latlon, pt.latlon), pt ] }
        .sort_by(&:first)
        .first

      pt ? pt[1] : nil
    end

    def wwc; (@waterways || []).count; end
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

      make(head, :meta,
        name: 'viewport',
        #content: 'width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no');
        content: 'user-scalable=no, initial-scale=1, maximum-scale=1, minimum-scale=1, width=device-width, height=device-height, target-densitydpi=device-dpi')
          #
          # https://stackoverflow.com/questions/4472891

      body = make(html, :body)

      # unit is meter ;-)
      # from one hex to the next there is 100m

      svg = make(body, :svg,
        id: 'svg-map',
        viewBox: '-50 -50 10000 10000',
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

      shexes = {}

      g.rows.each do |row|

        row.each do |point|

          loff = loffs[point.y % 2]

          px = loff + point.x * 100
          py = point.y * 1.5 * R1

          east = px
          south = py

          cla = point.ele == nil ? 's' : 'g'
          sh = make(
            svg,
            :use,
            href: '#h', class: cla, x: px, y: py, 'data-ll': point.to_data_ll)
          shexes[point.xy] = sh

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

      g.features.waterways
        .each { |w|
          w.hexes.each { |h|
            (h.waterways ||= Set.new) << w } }

      seen_segments = Set.new

      sinks = g.features.waterways
        .collect { |w|
          make_waterway(
            svg, w, seen_segments) }

        # TODO move the sea reconnect into make_waterway
        #
      g.features.waterways.zip(sinks)
        .each { |w, s|
          reconnect_waterway(
            svg, w, "ww #{w.tags['waterway']}", s, seen_segments) }

      #
      # draw ponds and lakes

      g.features.lakes
        .each { |l| make_lake(svg, l) }

      #
      # flag woods

      g.features.woods
        .each { |w| flag_wood(shexes, w) }

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

      makec(body, %{ generated with https://github.com/jmettraux/archelaus })

      east = east.to_i + 50
      south = south.to_i + 50
        #
      make(body, :script, "window._east = #{east}; window._south = #{south};")

      make(
        body,
        :div, { id: 'menu' },
        wrapf(File.join(__dir__, 'svg_menu.html')))
      make(
        body,
        :div, { id: 'help', style: 'display: none;' },
        wrapf(File.join(__dir__, 'svg_help.html')))

      make(body,
        :script,
        wrapf(File.join(__dir__, 'svg.js')))

      make(body,
        :script,
        "elt('#menu .name').innerHTML = \"&#8275; #{g.name} &#8275;\";") \
          if g.name

      puts(html.to_s)
    end

    protected

    def make(*args); Archelaus::Gen.make(*args); end
    def wrapt(text); Archelaus::Gen.wrapt(text); end
    def wrapf(path); Archelaus::Gen.wrapf(path); end
    def makec(parent, text); Archelaus::Gen.makec(parent, text); end

    def make_waterway(svg, way, seen_segments)

      hs = way.hexes.sort_by { |h| h.ele }

      d = []
      seen = []
      previous_hs = nil

      loop do

        hs.uniq!

        draw_waterway_segment(svg, way, hs.shift, hs, seen, d)

        break if hs.empty?

        sh, hh, cd = Archelaus.closest_ele_pair(seen, hs)
#make(svg, :path, class: 'red2', d: "M #{sh.sx} #{sh.sy} L #{hh.sx} #{hh.sy}")

        hh1 = sh.towards_higher(hh) || sh.towards(hh)

        hs.unshift(hh1)
        hs.unshift(sh)
#rp [ :cept, sh.xye, hh.xye, hh1.xye, hs.count, hs.uniq.count ]

        break if previous_hs == hs
        previous_hs = hs.dup
      end

      d = d.select { |s| ! seen_segments.include?(s) }
      d.each { |s| seen_segments << s }
      d = d.join(' ')

      k = "ww #{way.tags['waterway']}"

      make(svg, :path, class: k, d: d, 'data-t': way.t)

      seen.first
    end

    def draw_waterway_segment(svg, way, hex, hexes, seen, r)

      seen << hex

      dirs = hex.dirs.values

      h1s = hexes.select { |h| dirs.include?(h) && hex.ele < h.ele }

      #return [ seen, r ] if h1s.empty?
      h1s = hexes.select { |h| dirs.include?(h) } if h1s.empty?
        #
        # let's flow uphill here for just one hex...

      h1s.each do |hh|
        r << "M #{hex.sx} #{hex.sy} L #{hh.sx} #{hh.sy}"
        hexes.delete(hh)
      end
      h1s.each do |hh|
        draw_waterway_segment(svg, way, hh, hexes, seen, r)
      end if hexes.any?

      [ seen, r ]
    end

    def reconnect_waterway(svg, way, klass, lowest_hex, seen_segments)

      dirs = lowest_hex.dirs.values.reverse

      if sea = dirs.find { |d| d && d.ele == nil }

        # connect the lowest hex to an adjacent sea hex...

        wx, wy = lowest_hex.sxsy

        bearing = Archelaus.compute_bearing(lowest_hex.latlon, sea.latlon) - 90
        dx = 50 * Math.cos(bearing.to_rad)
        dy = 50 * Math.sin(bearing.to_rad)

        make(
          svg, :path,
          class: klass + ' mouth',
          d: "M #{wx} #{wy} L #{wx + dx} #{wy + dy}",
          'data-t': way.t + ', mouth')

      else

        # connect to a waterway downstream...

        dh = dirs
          .select { |d| d && d.ele < lowest_hex.ele }
          .sort_by(&:ele)
          .find { |d| d.waterways && ! d.waterways.include?(way) }
        if dh
          make(
            svg, :path,
            class: klass + ' conn', d: "M #{lowest_hex.sx_sy} L #{dh.sx_sy}",
            'data-t': way.t + ', (conn)')
            (dh.waterways ||= Set.new) << way
          return
        end
      end
    end

    def make_lake(svg, lake)

      k = "w #{lake.tags['water']}"
      t = lake.t

      lake.hexes.each do |h|

        make(svg, :circle, cx: h.sx, cy: h.sy, class: k, 'data-t': t)
      end
    end

    def flag_wood(shexes, wood)

      t = wood.t

      wood.hexes.each do |h|

        sh = shexes[h.xy]
        sh.atts[:class] = "#{sh.atts[:class]} wo"
        sh.atts[:'data-t'] = t
      end
    end
  end
end

