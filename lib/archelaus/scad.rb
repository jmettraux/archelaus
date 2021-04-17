
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

    def generate_scad(lat, lon, step, width, height, origin=:nw)

      puts File.read(File.join(__dir__, 'pre.scad'))

      g = compute_grid(lat, lon, step, width, height, origin)
      g.load_elevations
      #g.load_features

      puts "// ground"

      g.rows.each do |row|
        row.each do |point|
          puts point.to_scad if point.ele
        end
      end

      puts "// sea"

      g.rows.each do |row|
        row.each do |point|
          puts point.to_scad if point.ele == nil
        end
      end
    end
  end
end

