
module Archelaus

  OVERPASS_URI = 'http://overpass-api.de/api/interpreter'

  class << self

    def fetch_nodes(grid)

      p0p1 = grid.swne.collect(&:to_fixed5).join(',')

      q = %{
        [out:json];
        (
          way[waterway=river](#{p0p1});
          way[waterway=stream](#{p0p1});
          way[natural=water](#{p0p1});

          way[natural=wood](#{p0p1});
          way[landuse=forest](#{p0p1});

          way[amenity=place_of_worship](#{p0p1});

          node[historic](#{p0p1});
          node[natural=spring](#{p0p1});
        );
        (._;>;);
        out;
      }
        .split("\n").collect(&:strip).reject { |e| e[0, 1] == '#' }.join('')

      puts http_get(OVERPASS_URI, data: q)
    end
  end
end

# https://towardsdatascience.com/loading-data-from-openstreetmap-with-python-and-the-overpass-api-513882a27fd0

