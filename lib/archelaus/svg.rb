
module Archelaus

  class Point
    attr_accessor :el, :elev
    attr_accessor :dks
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
  font-size: 21;
  color: grey; font-family: sans-serif; font-weight: bolder;
  text-anchor: middle;
  opacity: 0.21; }
svg text.t.gx {
  color: lightgrey;
}
svg text.t.gn {
  font-size: 18;
  color: lightgrey;
}
svg text.t.mx {
}
svg text.t.mn {
  font-size: 18;
  color: lightgrey;
}

use[href="#h"].g {
  fill: none; stroke: lightgrey; stroke-width: 1; }
use[href="#h"].s {
  fill: none; stroke: blue; stroke-width: 1; opacity: 0.2; }

use[href="#sea"] { fill: none; stroke-width: 1; stroke: black; }
use[href="#ssea"] { fill: none; stroke-width: 1.2; stroke: black; }
use[href="#sswa"] { fill: none; stroke-width: 1; stroke: black; }
use[href="#swa"] { fill: none; stroke-width: 1; stroke: grey; }
use[href="#snwa"] { fill: none; stroke-width: 0.8; stroke: grey; }
use[href="#snea"] { fill: none; stroke-width: 1; stroke: grey; }
use[href="#seb"] { fill: none; stroke-width: 1; stroke: black; }
use[href="#sseb"] { fill: none; stroke-width: 1.2; stroke: black; }
use[href="#sswb"] { fill: none; stroke-width: 1; stroke: black; }
use[href="#swb"] { fill: none; stroke-width: 1; stroke: grey; }
use[href="#snwb"] { fill: none; stroke-width: 0.8; stroke: grey; }
use[href="#sneb"] { fill: none; stroke-width: 1; stroke: grey; }
use[href="#sec"] { fill: none; stroke-width: 1; stroke: black; }
use[href="#ssec"] { fill: none; stroke-width: 1.2; stroke: black; }
use[href="#sswc"] { fill: none; stroke-width: 1; stroke: black; }
use[href="#swc"] { fill: none; stroke-width: 1; stroke: grey; }
use[href="#snwc"] { fill: none; stroke-width: 0.8; stroke: grey; }
use[href="#snec"] { fill: none; stroke-width: 1; stroke: grey; }

use[href="#H"] {
  fill: none; stroke: lightgrey; stroke-width: 2; }

#patterns {
  display: none; }
      })

      body = maken(html, :body)

      # unit is meter ;-)
      # from one hex to the next there is 100m

      #viewbox = [ 0, 0, 300 * 100, 300 * 100 ]
      #viewbox = [ 0, 0, 300 * 20, 300 * 20 ]
      #viewbox = [ 0, 0, 5000, 5000 ]
      #viewbox = [ 8925, -689, 5000, 5000 ]
      viewbox = [ 10425, 111, 3000, 3000 ]

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
          " L 0 #{-R1}",
        fill: 'none')

      { a: 0.80, b: 0.70, c: 0.60 }.each do |k, v|

        s = 6
        d = s.times
          .collect { |i|
            dy = 0.88 * DY
            #"M #{(i == 0 ? 0.87 : 0.66) * R0} #{-dy + i * R1 / s}" +
            "M #{(i == 0 ? 0.87 : v) * R0} #{-dy + i * R1 / s}" +
            " L #{R0} #{-dy + i * R1 / s}" }
          .join(' ')

        maken(pats, :path, id: "se#{k}", d: d)
        maken(pats, :path, id: "sse#{k}", d: d, transform: 'rotate(60)')
        maken(pats, :path, id: "ssw#{k}", d: d, transform: 'rotate(120)')
        maken(pats, :path, id: "sw#{k}", d: d, transform: 'rotate(180)')
        maken(pats, :path, id: "snw#{k}", d: d, transform: 'rotate(240)')
        maken(pats, :path, id: "sne#{k}", d: d, transform: 'rotate(300)')
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
          " L 0 #{-R1 * 10}",
        fill: 'none')

      loffs =
        g[0, 0].lon < g[0, 1].lon ?
        [ 0, R0 ] :
        [ R0, 0 ]
#STDERR.puts g[0, 0].lon
#STDERR.puts p g[0, 1].lon

      #emin, emax = g.elevations
      #delta = emax - emin
      #ed1 = emin + delta * 0.25
      #ed2 = emin + delta * 0.75
#STDERR.puts [ :emin, emin, :emax, emax ].inspect
#STDERR.puts [ :ed1, ed1, :ed2, ed2 ].inspect
      #dirs = %i[ e se sw w nw ne ]
      #g.rows.each do |row|
      #  row.each do |point|
      #    dirs.each do |d|
      #      dp = point.send(d); next unless dp
      #      point.send("#{d}_d=", (dp.k
      #    end
      #  end
      #end

      #d0 = g.maxd * 0.1
      d0 = 5.0
      d1 = g.maxd * 0.33
      d2 = g.maxd * 0.66
#STDERR.puts [ d0, d1, d2, '<-', g.maxd ].inspect

      g.rows.each do |row|
        row.each do |point|
          point.elev = point.ele ? (point.ele * 100).to_i : -100
          point.el = point.ele ? (point.ele / 10).round : -1
#STDERR.puts point.ds.inspect
          point.dks = point.ds
            .inject({}) { |h, (k, v)|
              if v > d0 && v < d1;      h[k] = :a
              elsif v >= d1 && v < d2;  h[k] = :b
              elsif v >= d2;            h[k] = :c
              end
              h } if point.ds
#STDERR.puts(point.dks.inspect) if point.dks && point.dks.values.include?(:c)
        end
      end

      #g.rows.each do |row|
      g.rows[0, 160].each do |row|

        #row.each do |point|
        row[0, 180].each do |point|

          loff = loffs[point.y % 2]

          px = loff + point.x * 100
          py = point.y * 1.5 * R1

          cla = point.ele == nil ? 's' : 'g'
          maken(svg, :use, href: '#h', class: cla, x: px, y: py)

          if (
            point.x % 10 == 0 && point.y % 20 == 0 ||
            point.x % 10 == 5 && point.y % 20 == 10
          ) then
            maken(svg, :use, href: '#H', x: px, y: py)
          end

          #eel = point.e ? point.e.el : -1
          #seel = point.se ? point.se.el : -1
          #swel = point.sw ? point.sw.el : -1
          #wel = point.w ? point.w.el : -1
          #nwel = point.nw ? point.nw.el : -1
          #neel = point.ne ? point.ne.el : -1
#if point.xy == [ 106, 3 ]
#  STDERR.puts "---"
#  STDERR.puts point.inspect
#  STDERR.puts [ :e, point.e ].inspect
#  STDERR.puts [ :se, point.se ].inspect
#  STDERR.puts [ :sw, point.sw ].inspect
#  STDERR.puts [ :w, point.w ].inspect
#  STDERR.puts [ :nw, point.nw ].inspect
#  STDERR.puts [ :ne, point.ne ].inspect
#end

          #maken(svg, :use, href: '#s0', x: px, y: py) if point.el > eel
          #maken(svg, :use, href: '#s1', x: px, y: py) if point.el > seel
          #maken(svg, :use, href: '#s2', x: px, y: py) if point.el > swel
          #maken(svg, :use, href: '#s3', x: px, y: py) if point.el > wel
          #maken(svg, :use, href: '#s4', x: px, y: py) if point.el > nwel
          #maken(svg, :use, href: '#s5', x: px, y: py) if point.el > neel
          point.dks
            .each { |k, v| maken(svg, :use, href: "#s#{k}#{v}", x: px, y: py)
              } if point.dks

          if point.ele

            eel = point.e ? point.e.el : -1
            seel = point.se ? point.se.el : -1
            swel = point.sw ? point.sw.el : -1
            wel = point.w ? point.w.el : -1
            nwel = point.nw ? point.nw.el : -1
            neel = point.ne ? point.ne.el : -1

            eelev = point.e ? point.e.elev : -1
            seelev = point.se ? point.se.elev : -1
            swelev = point.sw ? point.sw.elev : -1
            welev = point.w ? point.w.elev : -1
            nwelev = point.nw ? point.nw.elev : -1
            neelev = point.ne ? point.ne.elev : -1

            elevs = [
              eelev, seelev, swelev, welev, nwelev, neelev, point.elev ]
            els = [
              eel, seel, swel, wel, nwel, neel, point.el ]

            locals = [
              point.e, point.se, point.sw, point.w, point.nw, point.ne
                ].compact
            ledge = locals
              .select { |pt| pt.el == point.el }

            k =
              if ledge.all? { |pt| pt.elev < point.elev }
                #'t gx' # ledge max
                nil
              elsif ledge.all? { |pt| pt.elev > point.elev }
                #'t gn' # ledge min
                nil
              elsif elevs.min == point.elev
                't mn' # hole
              elsif elevs.max == point.elev
                't mx' # summit
              else
                nil
              end

k = k || 't mn'
            maken(svg, :text,
              #point.ele.to_i.to_s + 'm',
              point.ele.to_fixed1,
              #point.el.to_s,
              #"#{point.ele.to_i} #{point.xy.join(',')}",
              class: k, x: px, y: py + R0 / 4
                ) if k
          end
        end
      end

      maken(body, :script) << Ox::Raw.new(%{
var clog = console.log;

var svg = document.getElementById('svg-map');
var inc = 1000;

function getViewBox() {

  var vb = svg.getAttribute('viewBox');
  var m = vb.match(/(-?[0-9]+) (-?[0-9]+) (-?[0-9]+) (-?[0-9]+)/);

  return {
    x: parseInt(m[1], 10), y: parseInt(m[2], 10),
    w: parseInt(m[3], 10), h: parseInt(m[4], 10) }
};

document.body.addEventListener('keyup', function(ev) {

  var vb = getViewBox();

  var c = ev.keyCode;
       if (c === 72) { vb.x = vb.x - inc; }
  else if (c === 74) { vb.y = vb.y + inc; }
  else if (c === 75) { vb.y = vb.y - inc; }
  else if (c === 76) { vb.x = vb.x + inc; }
  else if (c === 78 || c === 34) { vb.w = vb.w + inc; vb.h = vb.h + inc; }
  else if (c === 77 || c === 33) { vb.w = vb.w - inc; vb.h = vb.h - inc; }
  else if (c === 37) { vb.x = vb.x - (inc / 10); }
  else if (c === 39) { vb.x = vb.x + (inc / 10); }
  else if (c === 38) { vb.y = vb.y - (inc / 10); }
  else if (c === 40) { vb.y = vb.y + (inc / 10); }
  else { clog(c); return; }

  svg.setAttribute(
    'viewBox',
    '' + vb.x + ' ' + vb.y + ' ' + vb.w + ' ' + vb.h);
});

svg.addEventListener('click', function(ev) {

  var pt = svg.createSVGPoint(); pt.x = ev.clientX; pt.y = ev.clientY;
  var xy =  pt.matrixTransform(svg.getScreenCTM().inverse());

  var vb = getViewBox();

  vb.x = (xy.x - vb.w / 2).toFixed(0);
  vb.y = (xy.y - vb.h / 2).toFixed(0);

  svg.setAttribute(
    'viewBox',
    '' + vb.x + ' ' + vb.y + ' ' + vb.w + ' ' + vb.h);
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

