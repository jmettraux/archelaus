
# https://www.opentopodata.org/api/

# europe !
# curl "https://api.opentopodata.org/v1/eudem25m?locations=57.688709,11.976404|57.2,11.8"

# To keep the public API sustainable some limitations are applied.
#
# Max 100 locations per request.
# Max 1 call per second.
# Max 1000 calls per day.

module Archelaus

  class << self

    def fetch_elevations(grid_or_points_or_latlons)

      fetch_elevations_list(
        grid_or_points_or_latlons.respond_to?(:points) ?
        grid_or_points_or_latlons.points :
        grid_or_points_or_latlons)
    end

    protected

    def fetch_elevations_list(points_or_latlons)

      points_or_latlons
        .reject { |p_or_ll| has_elevation?(p_or_ll) }
        .each_slice(100) { |ps_or_lls| fetch_elevations_100(ps_or_lls) }
    end

    ELEVATION_URI = 'https://api.opentopodata.org/v1/eudem25m'
      #?locations=57.688709,11.976404|57.2,11.8"

    def fetch_elevations_100(points_or_latlons)

      fail ArgumentError.new(
        "too many points or latlons #{points_or_latlons.length} > 100"
      ) if points_or_latlons.length > 100

      ls = points_or_latlons
        .collect { |p_or_ll|
          lat, lon = to_latlon(p_or_ll)
          "#{lat.to_fixed5},#{lon.to_fixed5}" }
        .join('|')

      res = http_get(ELEVATION_URI, locations: ls)
      es = JSON.parse(res)['results'].collect { |e| e['elevation'] }

      points_or_latlons.zip(es).each do |p_or_ll, e|
        save_elevation(p_or_ll, e)
      end
    end

    def save_elevation(point_or_latlon, elevation)

      lat, lon = to_latlon(point_or_latlon)

      File.open(elevation_filename(point_or_latlon), 'wb') do |f|
        f.print(JSON.dump(lat: lat, lon: lon, ele: elevation))
      end
    end

    def has_elevation?(point_or_latlon)

      File.exist?(elevation_filename(point_or_latlon))
    end

    def load_elevation(point_or_latlon)

      JSON.parse(File.read(elevation_filename(point_or_latlon)))
    end

    def elevation_filename(point_or_latlon)

      lat, lon = to_latlon(point_or_latlon)

      "var/elevations/e__#{lat.to_fixed5}__#{lon.to_fixed5}.json"
    end

    def to_latlon(point_or_latlon)

      point_or_latlon.is_a?(Array) ? point_or_latlon : point_or_latlon.latlon
    end
  end

  class Point

    attr_accessor :ds
  end

  class Grid

    DIRS = %i[ e se sw w nw ne ]
    SEA_LEVEL = -10.0

    attr_reader :maxd

    def load_elevations

      @maxd = 0

      each_point do |point|
        d = Archelaus.send(:load_elevation, point) rescue {}
        point.ele = d['ele']
      end
      each_point do |point|
        next unless point.ele
        point.ds = {}
        DIRS.each do |d|
          dp = point.send(d); next unless dp
          delta = point.ds[d] = point.ele - (dp.ele || SEA_LEVEL)
#STDERR.puts [ point.xy, point.ele, d, dp.xy, dp.ele, '->', delta ].inspect \
#  if delta > @maxd
          @maxd = delta if delta > @maxd
        end
      end
#STDERR.puts @maxd.inspect

      nil
    end
  end
end

