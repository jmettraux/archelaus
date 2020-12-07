
module Archelaus

  class << self

    def compute_line(lat, lon, step, bearing, count)

      lat1, lon1 = lat, lon

      [ [ lat, lon ] ] +
      (count - 1).times
        .collect {
          lat1, lon1 = compute_point(lat1, lon1, bearing, step)
          [ lat1, lon1 ] }
    end

    def compute_grid(lat, lon, step, width, height)

      compute_line(lat, lon, step, 180.0, height)
        .collect { |lat0, lon0| compute_line(lat0, lon0, step, 90.0, width) }
    end
  end
end


# 300 by 300
# 30km by 30km

