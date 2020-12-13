
module Archelaus

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

      #maken(head, :style, %{ TODO RESET

      maken(head, :style, %{
body { margin: 0; padding: 0; }
      })

      body = maken(html, :body)

      # unit is meter ;-)
      # from one hex to the next there is 100m

      #viewbox = [ 0, 0, 300 * 100, 300 * 100 ]
      #viewbox = [ 0, 0, 300 * 20, 300 * 20 ]
      viewbox = [ 0, 0, 300, 300 ]

      svg = maken(body, :svg,
        viewBox: viewbox.collect(&:to_s).join(' '),
        preserveAspectRatio: 'xMinYMin slice',
        xmlns: 'http://www.w3.org/2000/svg')
        #width: '700px', height: '500px',

      maken(svg, :path,
        id: 'h',
        d:
          "M 0 #{-R1}" +
          " L #{R0} #{-DY}" +
          " L #{R0} #{DY}" +
          " L 0 #{R1}" +
          " L #{-R0} #{DY}" +
          " L #{-R0} #{-DY}" +
          " L 0 #{-R1}",
        fill: 'none', 'stroke-width': 1)

      s = 8
      d = s.times
        .collect { |i|
          dy = 0.88 * DY
          "M #{0.8 * R0} #{-dy + i * R1 / s} L #{R0} #{-dy + i * R1 / s}" }
        .join(' ')

      maken(svg, :path,
        id: 's', d: d, fill: 'none', 'stroke-width': 1)
      maken(svg, :path,
        id: 's1', d: d, fill: 'none', 'stroke-width': 1, transform: 'rotate(60)')

      loffs = [ 0, R0 ]
      loffs.reverse! if g[0][0].lon < g[1][0].lon

#p g[0, 0]
#p g.elevations
      #maken(svg, :use, href: '#hex', stroke: 'black', x: 0, y: 0)
      #maken(svg, :use, href: '#hex', stroke: 'black', x: R0, y: R0)
      #maken(
      #  svg, :use,
      #  href: '#slp', stroke: 'black', x: R0, y: R0)
      #maken(
      #  svg, :use,
      #  href: '#slp', stroke: 'black', x: 0, y: 0,
      #  transform: "rotate(50, 50, 10)")

      g.rows[0, 2].each do |row|
        row[0, 2].each do |point|
          loff = loffs[point.y % 2]
          color = point.ele == nil ? 'blue' : 'black'
          maken(svg, :use,
            href: '#h',
            #id: point.id,
            stroke: color,
            x: loff + point.x * 100, y: point.y * 1.5 * R1)

          maken(svg, :use,
            href: '#s', stroke: 'black',
            x: loff + point.x * 100, y: point.y * 1.5 * R1
              ) if point.xy == [ 0, 1 ]
          maken(svg, :use,
            href: '#s1', stroke: 'black',
            x: loff + point.x * 100, y: point.y * 1.5 * R1,
              ) if point.xy == [ 1, 1 ]
        end
      end

      Ox.dump(doc)
    end

    protected

    def maken(parent, tag, text=nil, atts={})

      if text.is_a?(Hash)
        atts = text
        text = nil
      end

      e = Ox::Element.new(tag.to_s)
      atts.each { |k, v| e[k] = v }
      e << text if text

      parent << e

      e
    end
  end
end

