# A sorted set of comparable elements where T implements #succ and #pred,
# optimized for low memory usage the less gaps there are between elements.
class RangeSet(T)
  include Enumerable(T)

  def initialize(range : Enumerable(T))
    @first = RangeNode(T).new(range.min, range.max)
  end

  def initialize
    @first = nil
  end

  def includes?(val : T) : Bool
    each_range do |r|
      if r.min <= val <= r.max
        return true
      end
    end

    false
  end

  def <<(val : T) : self
    unless r = @first
      @first = RangeNode(T).new(val, val)
      return self
    end

    pred = nil
    while r
      if val < r.min
        if val.succ == r.min
          if pred && pred.max.succ.succ == r.min
            pred.succ = r.succ
            pred.max = r.max
          else
            r.min = val
          end
        else
          if pred
            if pred.max.succ == val
              pred.max = val
            else
              pred.succ = RangeNode(T).new(val, val, r)
            end
          else
            @first = RangeNode(T).new(val, val, r)
          end
        end

        return self
      elsif val <= r.max
        return self
      end

      pred = r
      r = r.succ
    end

    if pred
      if pred.max.succ == val
        pred.max = val
        return self
      end

      pred.succ = RangeNode(T).new(val, val)
    end

    self
  end

  def delete(val : T) : Bool
    return false unless r = @first

    if val < r.min
      return false
    end
    pred = nil
    while r
      if r.min <= val <= r.max
        if r.min == r.max
          if pred
            pred.succ = r.succ
          else
            @first = r.succ
          end
        elsif val == r.min
          r.min = val.succ
        elsif val == r.max
          r.max = val.pred
        else
          new_range = RangeNode(T).new(val.succ, r.max, r.succ)
          r.max = val.pred
          r.succ = new_range
        end

        return true
      end

      pred = r
      r = r.succ
    end

    false
  end

  def each(& : T ->) : Nil
    each_range { |r| r.min.upto(r.max) { |n| yield n } }
  end

  def to_s(io : IO)
    io << self.class << " {"

    r = @first
    while r
      if r.min == r.max
        io << r.max
      else
        io << r.min << ".." << r.max
      end

      if r = r.succ
        io << ", "
      end
    end

    io << '}'
  end

  def inspect(io : IO)
    io << self.class << " {"

    r = @first
    while r
      if r.min == r.max
        r.max.inspect(io)
      else
        r.min.inspect(io)
        io << ".."
        r.max.inspect(io)
      end

      if r = r.succ
        io << ", "
      end
    end

    io << '}'
  end

  def clear : self
    @first = nil
    self
  end

  private def each_range
    r = @first
    while r
      yield r
      r = r.succ
    end
  end

  private class RangeNode(T)
    property_initializer min : T, max : T, succ : self? = nil
  end
end
