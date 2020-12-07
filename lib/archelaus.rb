
require 'additions'


module Archelaus

  EARTH_RADIUS = 6378.1 # km

  class << self

    def compute_distance(lat0, lon0, lat1, lon1)

      dlat = (lat1 - lat0).to_rad
      dlon = (lon1 - lon0).to_rad

      a =
        Math.sin(dlat / 2) ** 2 +
        Math.cos(lat0.to_rad) * Math.cos(lat1.to_rad) * Math.sin(dlon / 2) ** 2

      EARTH_RADIUS * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
    end

    def compute_point(lat, lon, bearing, distance)

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

