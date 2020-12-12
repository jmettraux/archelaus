
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

