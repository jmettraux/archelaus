
module Archelaus

  class Point

    def to_scad(min_ele=0)

      if ele == nil
        "shex(#{x}, #{y});"
      else
        "hex(#{x}, #{y}, #{ele - min_ele}); // #{lat} / #{lon}"
      end
    end
  end

  class << self

    def generate_scad(
      lat, lon, step, width, height,
      origin=:nw,
      x0=0, y0=0, x1=width, y1=height
    )

      puts File.read(File.join(__dir__, 'pre.scad'))

      g = compute_grid(lat, lon, step, width, height, origin)
      g.load_elevations
      #g.load_features

      puts
      puts "// original grid:"
      puts "//"
      puts "// NW: lat #{g.nw.lat.to_fixed5}  lon #{g.nw.lon.to_fixed5}"
      puts "// lowest elevation:   #{(g.lowest_ele || 0).inspect}m"
      puts "// highest elevation:  #{g.highest_ele.inspect}m"

      if [ x0, y0, x1, y1 ] != [ 0, 0, width, height ]

        g = g.crop(x0, y0, x1, y1)
        g.load_elevations

        puts
        puts "// cropped grid:"
        puts "//"
        puts "// [ #{x0}, #{y0} ] -> [ #{x1}, #{y1} ]"
        puts "//"
        puts "// NW: lat #{g.nw.lat.to_fixed5}  lon #{g.nw.lon.to_fixed5}"
        puts "// lowest elevation:   #{(g.lowest_ele || 0).inspect}m"
        puts "// highest elevation:  #{g.highest_ele.inspect}m"
      end

      puts
      puts "// ground"

      g.rows.each_with_index do |row, y|
        row.each do |point|
          puts point.to_scad(g.lowest_ele - 0.2) if point.ele
        end
      end

      puts
      puts "// sea"

      if g.lowest_ele == nil
        puts "sea(0, 0, #{g.width - 1}, #{g.height - 1});"
      end

      puts
    end
  end
end

