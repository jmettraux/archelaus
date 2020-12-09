
require 'cgi'
require 'json'
require 'net/http'

require 'additions'


module Archelaus

  EARTH_RADIUS = 6378100.0 # m

  class << self

    # http://www.movable-type.co.uk/scripts/latlong.html

    def compute_distance(*points)

      lat0, lon0, lat1, lon1 = points.flatten

      dlat = (lat1 - lat0).to_rad
      dlon = (lon1 - lon0).to_rad

      a =
        Math.sin(dlat / 2) ** 2 +
        Math.cos(lat0.to_rad) * Math.cos(lat1.to_rad) * Math.sin(dlon / 2) ** 2

      EARTH_RADIUS * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    end

    def compute_distances(*points)

      lat0, lon0, lat1, lon1 = points.flatten

      { height: compute_distance(lat0, lon0, lat1, lon0).abs,
        width: compute_distance(lat1, lon0, lat1, lon1).abs,
        diag: compute_distance(lat0, lon0, lat1, lon1).abs }
    end

    def compute_bearing(*points)

      lat0, lon0, lat1, lon1 = points.flatten

      dlon = (lon1 - lon0).to_rad
      lat0 = lat0.to_rad
      lat1 = lat1.to_rad

      y =
        Math.sin(dlon) * Math.cos(lat1)
      x =
        Math.cos(lat0) * Math.sin(lat1) -
        Math.sin(lat0) * Math.cos(lat1) * Math.cos(dlon)

      Math.atan2(y, x).to_deg
    end

    def compute_point(*point, bearing, distance)

      lat, lon, bearing, distance = [ point, bearing, distance ].flatten

      lat = lat.to_rad
      lon = lon.to_rad
      bearing = bearing.to_rad

      lat1 =
        Math.asin(
          Math.sin(lat) * Math.cos(distance / EARTH_RADIUS) +
          Math.cos(lat) * Math.sin(distance / EARTH_RADIUS) * Math.cos(bearing))
      lon1 =
        lon +
        Math.atan2(
          Math.sin(bearing) * Math.sin(distance / EARTH_RADIUS) * Math.cos(lat),
          Math.cos(distance / EARTH_RADIUS) - Math.sin(lat) * Math.sin(lat1))

      [ lat1.to_deg, lon1.to_deg ]
    end
  end
end

require 'archelaus/http'
require 'archelaus/hexgrid'
require 'archelaus/overpass'
require 'archelaus/elevation'

