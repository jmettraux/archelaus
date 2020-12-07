
module Archelaus

  class << self

    def compute_row(lat, lon, step, width)

      lat1, lon1 = lat, lon

      [ [ lat, lon ] ] +
      (width - 1).times
        .collect {
          lat1, lon1 = compute_point(lat1, lon1, 90.0, step)
          [ lat1, lon1 ] }
    end

    def compute_grid(lat, lon, step, width, height)

      compute_row(lat, lon, step, width)
    end
  end
end

