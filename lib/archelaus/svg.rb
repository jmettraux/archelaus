
module Archelaus

  class Point
    attr_accessor :el, :elev
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
body {
  margin: 0;
  padding: 0; }
svg text.t {
  color: grey;
  font-size: 30; font-family: sans-serif; font-weight: bolder;
  text-anchor: middle;
  opacity: 0.05; }
use[href="#h"].g {
  fill: none; stroke: lightgrey; stroke-width: 1; }
use[href="#h"].s {
  fill: none; stroke: blue; stroke-width: 1; opacity: 0.2; }
path.sl {
  fill: none; stroke: black; stroke-width: 1 }
#patterns {
  display: none; }
      })

      body = maken(html, :body)

      # unit is meter ;-)
      # from one hex to the next there is 100m

      #viewbox = [ 0, 0, 300 * 100, 300 * 100 ]
      #viewbox = [ 0, 0, 300 * 20, 300 * 20 ]
      viewbox = [ 0, 0, 4000, 4000 ]

      svg = maken(body, :svg,
        id: 'svg-map',
        viewBox: viewbox.collect(&:to_s).join(' '),
        preserveAspectRatio: 'xMinYMin slice',
        xmlns: 'http://www.w3.org/2000/svg',
        width: '100%', height: '100%')

      pats = maken(svg, :g, id: 'patterns')

      maken(pats, :path,
        id: 'h',
        d:
          "M 0 #{-R1}" +
          " L #{R0} #{-DY}" +
          " L #{R0} #{DY}" +
          " L 0 #{R1}" +
          " L #{-R0} #{DY}" +
          " L #{-R0} #{-DY}" +
          " L 0 #{-R1}",
        fill: 'none')

      s = 6
      d = s.times
        .collect { |i|
          dy = 0.88 * DY
          "M #{(i == 0 ? 0.87 : 0.66) * R0} #{-dy + i * R1 / s}" +
          " L #{R0} #{-dy + i * R1 / s}" }
        .join(' ')

      maken(pats, :path, id: 's0', class: 'sl', d: d)
      maken(pats, :path, id: 's1', class: 'sl', d: d, transform: 'rotate(60)')
      maken(pats, :path, id: 's2', class: 'sl', d: d, transform: 'rotate(120)')
      maken(pats, :path, id: 's3', class: 'sl', d: d, transform: 'rotate(180)')
      maken(pats, :path, id: 's4', class: 'sl', d: d, transform: 'rotate(240)')
      maken(pats, :path, id: 's5', class: 'sl', d: d, transform: 'rotate(300)')

      loffs = [ 0, R0 ]
      loffs.reverse! if g[0][0].lon < g[1][0].lon

      g.rows.each do |row|
        row.each do |point|
          point.elev = point.ele ? (point.ele * 100).to_i : -100
          point.el = point.ele ? (point.ele / 10).round : -1
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

      g.rows[0, 100].each do |row|

        row[0, 200].each do |point|

          loff = loffs[point.y % 2]
          cla = point.ele == nil ? 's' : 'g'
          maken(svg, :use,
            href: '#h', class: cla,
            #id: point.id,
            x: loff + point.x * 100, y: point.y * 1.5 * R1)

          eel = point.e ? point.e.el : -1
          seel = point.se ? point.se.el : -1
          swel = point.sw ? point.sw.el : -1
          wel = point.w ? point.w.el : -1
          nwel = point.nw ? point.nw.el : -1
          neel = point.ne ? point.ne.el : -1
            #
          eelev = point.e ? point.e.elev : -1
          seelev = point.se ? point.se.elev : -1
          swelev = point.sw ? point.sw.elev : -1
          welev = point.w ? point.w.elev : -1
          nwelev = point.nw ? point.nw.elev : -1
          neelev = point.ne ? point.ne.elev : -1

          maken(svg, :use,
            href: '#s0',
            x: loff + point.x * 100, y: point.y * 1.5 * R1) if point.el > eel
          maken(svg, :use,
            href: '#s1',
            x: loff + point.x * 100, y: point.y * 1.5 * R1) if point.el > seel
          maken(svg, :use,
            href: '#s2',
            x: loff + point.x * 100, y: point.y * 1.5 * R1) if point.el > swel
          maken(svg, :use,
            href: '#s3',
            x: loff + point.x * 100, y: point.y * 1.5 * R1) if point.el > wel
          maken(svg, :use,
            href: '#s4',
            x: loff + point.x * 100, y: point.y * 1.5 * R1) if point.el > nwel
          maken(svg, :use,
            href: '#s5',
            x: loff + point.x * 100, y: point.y * 1.5 * R1) if point.el > neel


          if point.ele
            elevs = [ eelev, seelev, swelev, welev, nwelev, neelev, point.elev ]
            els = [ eel, seel, swel, wel, nwel, neel, point.el ]
            #if (
            #  #eles.count { |e| e == point.el } == 1 &&
            #  (eles.min == point.el || eles.max == point.el)
            #) then
            if (
              (elevs.min == point.elev || elevs.max == point.elev)
            ) then
              maken(svg, :text,
                point.ele.to_i.to_s + 'm',
                #point.el.to_s,
                class: 't',
                x: loff + point.x * 100, y: point.y * 1.5 * R1 + R0 / 4)
            end
          end
        end
      end

      maken(body, :script) << Ox::Raw.new(%{
var clog = console.log;
var inc = 1000;

document.body.addEventListener('keyup', function(ev) {

  //clog(ev.keyCode);
  // "h" 72
  // "l" 76

  var map = document.getElementById('svg-map');
  var vb = map.getAttribute('viewBox');

  var m = vb.match(/(-?[0-9]+) (-?[0-9]+) (-?[0-9]+) (-?[0-9]+)/);
  var x = parseInt(m[1], 10);
  var y = parseInt(m[2], 10);
  var w = parseInt(m[3], 10);
  var h = parseInt(m[4], 10);

  if (ev.keyCode === 72) { x = x - inc; }
  else if (ev.keyCode === 74) { y = y + inc; }
  else if (ev.keyCode === 75) { y = y - inc; }
  else if (ev.keyCode === 76) { x = x + inc; }
  else if (ev.keyCode === 78) { w = w + inc; h = h + inc; }
  else if (ev.keyCode === 77) { w = w - inc; h = h - inc; }
  else { clog(ev.keyCode); return; }

  map.setAttribute('viewBox', '' + x + ' ' + y + ' ' + w + ' ' + h);
});
      })

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

