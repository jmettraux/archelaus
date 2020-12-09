
module Archelaus

  OVERPASS_URI = 'http://overpass-api.de/api/interpreter'

  class << self

    def get_elements(point0, point1)

      point0, point1 = point1, point0 if point0[1] < point1[1]
      p0p1 = "#{point0[0]},#{point0[1]},#{point1[0]},#{point1[1]}"

return
      q = %{
        [out:json];
        (
          node(#{p0p1});
          way(#{p0p1});
          relation(#{p0p1});
          area(#{p0p1});
        );
        out;
      }
        .split("\n").collect(&:strip).reject { |e| e[0, 1] == '#' }.join('')

      JSON.parse(http_get(OVERPASS_URI, data: q))
    end
  end
end

