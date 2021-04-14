
class Float

  def sign
    zero? ? 0 : negative? ? -1 : 1
  end

  def to_rad
    to_f / 180.0 * Math::PI
  end
  def to_deg
    to_f * 180.0 / Math::PI
  end

  def to_fixed5
    sprintf('%#.06f', self)[0..-2]
  end

  def to_fixed1; sprintf('%#.01f', self); end
  def to_fixed2; sprintf('%#.02f', self); end

  def to_fixed1s; sprintf('%#.01f', self).sub(/-/, '_'); end
end

