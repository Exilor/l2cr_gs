module Math
  def self.to_degrees(radians) : Float64
    radians.to_f64 * 180.0 / PI
  end

  def self.to_radians(degrees) : Float64
    degrees.to_f64 / 180.0 * PI
  end

  def self.pow(a, b) : Float64
    a.to_f64 ** b.to_f64
  end
end
