
module Archelaus

  class Point

    def to_scad

      if ele == nil
        "shex(#{x}, #{y});"
      else
        "hex(#{x}, #{y}, #{ele}); // #{lat} / #{lon}"
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

      puts "// original grid:"
      puts "//"
      puts "// NW: lat #{g.nw.lat.to_fixed5}  lon #{g.nw.lon.to_fixed5}"
      puts "// lowest elevation:   #{(g.lowest_ele || 0).inspect}m"
      puts "// highest elevation:  #{g.highest_ele.inspect}m"

      puts "// ground"

      g.rows.each_with_index do |row, y|
        next if y < y0 || y > y1
        row.each do |point|
          next if point.x < x0 || point.x > x1
          puts point.to_scad if point.ele
        end
      end

      puts "// sea"

      g.rows.each_with_index do |row, y|
        next if y < y0 || y > y1
        row.each do |point|
          next if point.x < x0 || point.x > x1
          puts point.to_scad if point.ele == nil
        end
      end
    end
  end
end

