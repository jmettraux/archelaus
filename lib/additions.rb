
class Float

  def to_rad
    to_f / 180.0 * Math::PI
  end
  def to_deg
    to_f * 180.0 / Math::PI
  end

  def to_fixed5
    sprintf('%#.06f', self)[0..-2]
  end
end

class Array

  def to_point_s

    lat, lon = self[0], self[1]

    return "#{lat.to_fixed5} #{lon.to_fixed5}" \
      if length == 2 && lat.is_a?(Float) && lon.is_a?(Float)

    fail(
      NoMethodError
        .new("undefined method `to_point_s' for #{self.inspect}:Array"))
  end
end

