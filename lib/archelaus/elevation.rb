
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

    def get_elevations(grid_or_points)

      if grid_or_points.is_a?(Array)
        get_elevations_grid(grid_or_points)
      else
        get_elevations_100(grid_or_points)
      end
    end

    protected

    def get_elevations_grid(grid)

      grid
        .flatten(1)
        .reject { |point| has_elevation?(point) }
        .each_slice(100) { |points| get_elevations_100(points) }

      grid.collect { |r| r.collect { |point| load_elevation(point) } }
    end

    ELEVATION_URI = 'https://api.opentopodata.org/v1/eudem25m'
      #?locations=57.688709,11.976404|57.2,11.8"

    def get_elevations_100(points)

      fail ArgumentError.new("too many points #{points.length} > 100") \
        if points.length > 100

      ls = points.collect { |pt| "#{pt[0]},#{pt[1]}" }.join('|')

      res = http_get(ELEVATION_URI, locations: ls)
      es = JSON.parse(res)['results'].collect { |e| e['elevation'] }

      points.zip(es).each do |point, e|
        save_elevation(point, e)
      end
    end

    def save_elevation(point, elevation)

      File.open(elevation_filename(point), 'wb') do |f|
        f.print(JSON.dump(lat: point[0], lon: point[1], ele: elevation))
      end
    end

    def has_elevation?(point)

      File.exist?(elevation_filename(point))
    end

    def load_elevation(point)

      JSON.parse(File.read(elevation_filename(point)))
    end

    def elevation_filename(point)

      "var/elevations/e__#{point[0].to_fixed5}__#{point[1].to_fixed5}.json"
    end
  end
end

