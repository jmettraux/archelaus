
module Archelaus

  class Point
    attr_accessor :el
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

      maken(head, :style, %{
body { margin: 0; padding: 0; }
svg text.t { font-size: 21; text-anchor: middle; }
use[href="#h"].g { fill: none; stroke: black; stroke-width: 1 }
use[href="#h"].s { fill: blue; stroke: blue; stroke-width: 1 }
path.sl { fill: none; stroke: black; stroke-width: 1 }
      })

      body = maken(html, :body)

      # unit is meter ;-)
      # from one hex to the next there is 100m

      #viewbox = [ 0, 0, 300 * 100, 300 * 100 ]
      #viewbox = [ 0, 0, 300 * 20, 300 * 20 ]
      viewbox = [ 0, 0, 4000, 4000 ]

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
          " L 0 #{-R1}")

      s = 6
      d = s.times
        .collect { |i|
          dy = 0.88 * DY
          "M #{(i == 0 ? 0.87 : 0.74) * R0} #{-dy + i * R1 / s}" +
          " L #{R0} #{-dy + i * R1 / s}" }
        .join(' ')

      maken(svg, :path, id: 's0', class: 'sl', d: d)
      maken(svg, :path, id: 's1', class: 'sl', d: d, transform: 'rotate(60)')
      maken(svg, :path, id: 's2', class: 'sl', d: d, transform: 'rotate(120)')
      maken(svg, :path, id: 's3', class: 'sl', d: d, transform: 'rotate(180)')
      maken(svg, :path, id: 's4', class: 'sl', d: d, transform: 'rotate(240)')
      maken(svg, :path, id: 's5', class: 'sl', d: d, transform: 'rotate(300)')

      loffs = [ 0, R0 ]
      loffs.reverse! if g[0][0].lon < g[1][0].lon

      g.rows.each do |row|
        row.each do |point|
          point.el = point.ele ? (point.ele / 10).to_i : 0
        end
      end

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

      g.rows[0, 31].each do |row|

        row[0, 299].each do |point|

          loff = loffs[point.y % 2]
          cla = point.ele == nil ? 's' : 'g'
          maken(svg, :use,
            href: '#h', class: cla,
            #id: point.id,
            x: loff + point.x * 100, y: point.y * 1.5 * R1)

          eel = point.e ? point.e.el : 0
          maken(svg, :use,
            href: '#s0',
            x: loff + point.x * 100, y: point.y * 1.5 * R1) if point.el > eel
          seel = point.se ? point.se.el : 0
          maken(svg, :use,
            href: '#s1',
            x: loff + point.x * 100, y: point.y * 1.5 * R1) if point.el > seel
          swel = point.sw ? point.sw.el : 0
          maken(svg, :use,
            href: '#s2',
            x: loff + point.x * 100, y: point.y * 1.5 * R1) if point.el > swel
          wel = point.w ? point.w.el : 0
          maken(svg, :use,
            href: '#s3',
            x: loff + point.x * 100, y: point.y * 1.5 * R1) if point.el > wel
          nwel = point.nw ? point.nw.el : 0
          maken(svg, :use,
            href: '#s4',
            x: loff + point.x * 100, y: point.y * 1.5 * R1) if point.el > nwel
          neel = point.ne ? point.ne.el : 0
          maken(svg, :use,
            href: '#s5',
            x: loff + point.x * 100, y: point.y * 1.5 * R1) if point.el > neel

          #if point.ele
          #  maken(svg, :text, point.ele.to_i.to_s + 'm',
          #    class: 't',
          #    x: loff + point.x * 100, y: point.y * 1.5 * R1)
          #end
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

