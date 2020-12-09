
module Archelaus

  OVERPASS_URI = 'http://overpass-api.de/api/interpreter'

  class << self

    def get_elements(*points)

      lat0, lon0, lat1, lon1 = points.flatten

      #point0, point1 = point1, point0 if point0[1] < point1[1]
      lat0, lon0, lat1, lon1 = lat1, lon1, lat0, lon0 if lon0 < lon1

      p0p1 = "#{lat0},#{lon0},#{lat1},#{lon1}"

      q = %{
        [out:json];
        #(
        #  node(#{p0p1});
        #  way(#{p0p1});
        #  relation(#{p0p1});
        #  area(#{p0p1});
        #);
          #node(#{p0p1});
          #relation[natural=wood](#{p0p1});
        #nwr(#{p0p1});
        (
          way(#{p0p1});
          relation(#{p0p1});
        );
        #>;
        out;
        #out geom;
        #out geom(#{p0p1});
      }
        .split("\n").collect(&:strip).reject { |e| e[0, 1] == '#' }.join('')

      puts http_get(OVERPASS_URI, data: q)
    end
  end
end

# https://towardsdatascience.com/loading-data-from-openstreetmap-with-python-and-the-overpass-api-513882a27fd0

