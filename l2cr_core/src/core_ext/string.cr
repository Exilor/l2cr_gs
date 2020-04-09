class String
  def casecmp?(other : String) : Bool
    compare(other, true) == 0
  end

  private record CaseCmpComparator, string : String

  def ===(other : CaseCmpComparator) : Bool
    casecmp?(other.string)
  end

  def casecmp : CaseCmpComparator
    CaseCmpComparator.new(self)
  end

  def match?(regex : Regex) : Bool
    regex === self
  end

  def starts_with?(arg1, arg2, *args)
    starts_with?(arg1) ||
    starts_with?(arg2) ||
    args.any? { |a| starts_with?(a) }
  end

  def ends_with?(arg1, arg2, *args)
    ends_with?(arg1) ||
    ends_with?(arg2) ||
    args.any? { |a| ends_with?(a) }
  end

  def from(pos : Int) : String
    self[pos..-1]
  end

  def to(pos : Int) : String
    self[0..pos]
  end

  def alnum? : Bool
    return false if empty?
    each_char { |c| return false unless c.alphanumeric? }
    true
  end

  def num? : Bool
    return false if empty?
    each_char { |c| return false unless c.number? }
    true
  end
end
