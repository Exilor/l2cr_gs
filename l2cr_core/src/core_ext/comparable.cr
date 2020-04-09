module Comparable(T)
  def clamp(min : T, max : T) : T
    self < min ? min : self > max ? max : self
  end

  def between?(min : T, max : T) : Bool
    min <= self <= max
  end
end
