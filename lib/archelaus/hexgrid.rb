
class Archelaus::Hexgrid

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
end

#pp compute_grid(52.204, 0.142, 0.1, 100, 100)
#p compute_distance(30.19, 71.51, 31.33, 74.21)

