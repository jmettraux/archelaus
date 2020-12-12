
module Archelaus

  class << self

    R0 = 100.0 / 2
    R1 = R0 / Math.cos((30.0).to_rad)

    DX = R0
    DY = R1 / 2

    def generate_svg(lat, lon, step, width, height, origin=:nw)

      g = compute_grid(lat, lon, step, width, height, origin)

      doc = Ox::Document.new

      svg = maken(
        doc,
        :svg,
        viewBox: '0 0 300 300', xmlns: 'http://www.w3.org/2000/svg')
      #svg = maken(doc, :svg, viewBox: '0 0 30000 30000')

      maken(
        svg,
        :path,
        id: 'hex',
        d:
          "M #{R0} 0 " +
          "L #{2 * R0} #{DY} " +
          "L #{2 * R0} #{DY + R1}" +
          "L #{R0} #{2 * R1}" +
          "L 0 #{DY + R1}" +
          "L 0 #{DY}" +
          "L #{R0} 0",
        stroke: 'black', fill: 'none', 'stroke-width': 3,
        transform: 'translate(0, 0)')

      3.times do |i|
        maken(svg, :use, href: '#hex', id: "h#{i}", x: i * 100)
      end
      3.times do |i|
        maken(svg, :use, href: '#hex', id: "h#{i}", x: 50 + i * 100, y: 1.5 * R1)
      end

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

