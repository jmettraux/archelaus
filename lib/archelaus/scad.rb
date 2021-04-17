
module Archelaus

  class Point

    def to_scad

      "hex(#{x}, #{y}, #{ele}); // #{lat} / #{lon}"
    end
  end

  class << self

    def generate_scad(lat, lon, step, width, height, origin=:nw)

      puts File.read(File.join(__dir__, 'pre.scad'))

      g = compute_grid(lat, lon, step, width, height, origin)
      g.load_elevations
      #g.load_features

      g.rows.each do |row|
        row.each do |point|
          next unless point.ele
          #p point
          puts point.to_scad
        end
      end
    end
  end
end

