
module Archelaus

  class << self

    def compute_line(lat, lon, step, bearing, count)

      lat1, lon1 = lat, lon
      bearings = Array(bearing)

      [ [ lat, lon ] ] +
      (count - 1).times
        .collect { |i|
          lat1, lon1 =
            compute_point(lat1, lon1, bearings[i % bearings.length], step)
          [ lat1, lon1 ] }
    end

    def compute_grid(lat, lon, step, width, height, origin=:nw)

      col_angles, row_angles =
        case origin
        when :ne then  [ [ 150.0, 210.0 ],                  90.0 + 180.0 ]
        when :sw then  [ [ 150.0 + 180.0, 210.0 + 180.0 ],  90.0 ]
        when :se then  [ [ 210.0 + 180.0, 150.0 + 180.0 ],  90.0 + 180.0 ]
        else           [ [ 150.0, 210.0 ],                  90.0 ] # nw
        end

      g = compute_line(lat, lon, step, col_angles, height)
        .collect { |lat0, lon0|
          compute_line(lat0, lon0, step, row_angles, width) }

#p [ g[0][0], g[-1][0] ]
      g.reverse! if g[0][0][0] < g[-1][0][0]
#p [ g[0][0], g[0][-1] ]
      g.each { |r| r.reverse! } if g[0][0][1] > g[0][-1][1]

      g
    end
  end
end


# 300 by 300
# 30km by 30km

