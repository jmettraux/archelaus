
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

      # unit is meter ;-)
      # from one hex to the next there is 100m

      #viewbox = [ 0, 0, 300 * 100, 300 * 100 ]
      #viewbox = [ 0, 0, 300 * 20, 300 * 20 ]
      viewbox = [ 0, 0, 300, 300 ]

      svg = maken(doc, :svg,
        viewBox: viewbox.collect(&:to_s).join(' '),
        preserveAspectRatio: 'xMinYMin slice',
        xmlns: 'http://www.w3.org/2000/svg')
        #width: '700px', height: '500px',

      maken(svg, :path,
        id: 'hex',
        d:
          "M #{R0} 0 " +
          "L #{2 * R0} #{DY} " +
          "L #{2 * R0} #{DY + R1}" +
          "L #{R0} #{2 * R1}" +
          "L 0 #{DY + R1}" +
          "L 0 #{DY}" +
          "L #{R0} 0",
        fill: 'none', 'stroke-width': 1)

      s = 8
      d = s.times
        .collect { |i|
          i = i + 0.5
          "M 0 #{DY + i * R1 / s} L #{0.2 * R0} #{DY + i * R1 / s}" }
        .join(' ')

      maken(svg, :path,
        id: 'slp', d: d, fill: 'none', 'stroke-width': 1)

      loffs = [ 0, R0 ]
      loffs.reverse! if g[0][0].lon < g[1][0].lon

#p g[0, 0]
#p g.elevations
      maken(svg, :use, href: '#hex', stroke: 'black', x: R0, y: R0)

      maken(
        svg, :use,
        href: '#slp', stroke: 'black', x: R0, y: R0)

      #g.rows.each do |row|
      #  row.each do |point|
      #    loff = loffs[point.y % 2]
      #    color = point.ele == nil ? 'blue' : 'black'
      #    maken(svg, :use,
      #      href: '#hex',
      #      #id: point.id,
      #      stroke: color,
      #      x: loff + point.x * 100, y: point.y * 1.5 * R1)
      #  end
      #end

      Ox.dump(doc)
    end

    protected

    def maken(parent, tag, atts)

      e = Ox::Element.new(tag.to_s)
      atts.each { |k, v| e[k] = v }
      parent << e

      e
    end
  end
end

