
module Archelaus

  class Point

    attr_accessor :dks

    #attr_accessor :el, :elev
    #point.elev = point.ele ? (point.ele * 100).to_i : -100
    #point.el = point.ele ? (point.ele / 10).round : -1
    def el; @el ||= (self.ele ? (self.ele / 10).round : -1); end

    def to_data_ll

      "#{lat.to_fixed5} #{lon.to_fixed5} #{ele ? ele.to_fixed1 : 's'}"
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

      doc = Ox::Document.new
      html = maken(doc, :html)
      head = maken(html, :head)
      maken(head, :title, 'archelaus')

      maken(head, :style) <<
        Ox::Raw.new(File.read(File.join(__dir__, 'svg.css')))

      body = maken(html, :body)

      # unit is meter ;-)
      # from one hex to the next there is 100m

      #viewbox = [ 0, 0, 300 * 100, 300 * 100 ]
      #viewbox = [ 0, 0, 300 * 20, 300 * 20 ]
      #viewbox = [ 0, 0, 5000, 5000 ]
      #viewbox = [ 8925, -689, 5000, 5000 ]
      viewbox = [ 0, 0, 2000, 2000 ]

      svg = maken(body, :svg,
        id: 'svg-map',
        viewBox: viewbox.collect(&:to_s).join(' '),
        preserveAspectRatio: 'xMinYMin slice',
        xmlns: 'http://www.w3.org/2000/svg',
        width: '100%', height: '100%')

      pats = maken(svg, :g, id: 'patterns')

      maken(pats, :path, # 100m hex
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

        maken(
          pats, :path, class: c, id: "se#{k}", d: d)
        maken(
          pats, :path, class: c, id: "sse#{k}", d: d, transform: 'rotate(60)')
        maken(
          pats, :path, class: c, id: "ssw#{k}", d: d, transform: 'rotate(120)')
        maken(
          pats, :path, class: c, id: "sw#{k}", d: d, transform: 'rotate(180)')
        maken(
          pats, :path, class: c, id: "snw#{k}", d: d, transform: 'rotate(240)')
        maken(
          pats, :path, class: c, id: "sne#{k}", d: d, transform: 'rotate(300)')
            #
            # hachures
      end

      maken(pats, :path, # 1km hex
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
          maken(
            svg,
            :use,
            href: '#h', class: cla, x: px, y: py, 'data-ll': point.to_data_ll)

          point.dks
            .each { |k, v| maken(svg, :use, href: "#s#{k}#{v}", x: px, y: py)
              } if point.dks

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

          maken(svg, :text,
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
      # draw kilometric hexes last (higher z)

      g.rows.each do |row|

        row.each do |point|

          loff = loffs[point.y % 2]

          px = loff + point.x * 100
          py = point.y * 1.5 * R1

          if (
            (point.x % 10 == 5 && point.y % 20 == 6) ||
            (point.x > 0 && point.x % 10 == 0 && point.y % 20 == 16)
          ) then
            maken(svg, :use, href: '#H', x: px, y: py)
          end
        end
      end

      east = east.to_i + 50
      south = south.to_i + 50
        #
      maken(body, :script) << %{
        window._east = #{east};
        window._south = #{south}; }

      menu = maken(body, :div, { id: 'menu' })
      maken(menu, :div, { class: 'latlon' }, '0.0 0.0')
      maken(menu, :div, { class: 'elevation' }, '0.0m')
      nav = maken(menu, :div, { class: 'nav' })

      maken(nav, :span, { class: 'nw' }, 'NW')
      maken(nav, :span, { class: 'ne' }, 'NE')
      maken(nav, :span, { class: 'c' }, 'C')
      maken(nav, :span, { class: 'sw' }, 'SW')
      maken(nav, :span, { class: 'se' }, 'SE')

      maken(body, :script) <<
        Ox::Raw.new(File.read(File.join(__dir__, 'svg.js')))

      Ox.dump(doc)
    end

    protected

    def maken(parent, tag, text=nil, atts={})

      text, atts = atts, text if text.is_a?(Hash)

      e = Ox::Element.new(tag.to_s)
      atts.each { |k, v| e[k] = v }
      e << text if text && text.is_a?(String)

      parent << e

      e
    end
  end
end

