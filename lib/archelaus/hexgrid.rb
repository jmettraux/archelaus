
def to_rad(d)
  d.to_f / 180.0 * Math::PI
end
def to_deg(r)
  r.to_f * 180.0 / Math::PI
end

ER = 6378.1 # km, radius of the Earth

def compute_distance(lat0, lon0, lat1, lon1)

  dlat = to_rad(lat1 - lat0)
  dlon = to_rad(lon1 - lon0)

  lat0 = to_rad(lat0)
  lat1 = to_rad(lat1)

  a =
    Math.sin(dlat / 2) ** 2 +
    Math.cos(lat0) * Math.cos(lat1) * Math.sin(dlon / 2) ** 2

  ER * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
end

def compute_point(lat, lon, bearing, distance)

  lat = to_rad(lat)
  lon = to_rad(lon)
  bearing = to_rad(bearing)

  lat1 =
    Math.asin(
      Math.sin(lat) * Math.cos(distance / ER) +
      Math.cos(lat) * Math.sin(distance / ER) * Math.cos(bearing))
  lon1 =
    lon +
    Math.atan2(
      Math.sin(bearing) * Math.sin(distance / ER) * Math.cos(lat),
      Math.cos(distance / ER) - Math.sin(lat) * Math.sin(lat1))

  [ to_deg(lat1), to_deg(lon1) ]
end

def compute_row(lat, lon, step, width)

  _, maxlon = compute_point(lat, lon, 90, width)

  row = [ [ lat, lon ] ]; loop do
      la, lo = row.last
      row << compute_point(la, lo, 90, step)
      break if row.any? && row.last[1] > maxlon
    end

  row
end

def compute_grid(lat, lon, step, height, width)

  compute_row(lat, lon, step, width)
end

#pp compute_grid(52.204, 0.142, 0.1, 100, 100)
p compute_distance(30.19, 71.51, 31.33, 74.21)

