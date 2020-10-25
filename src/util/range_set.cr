class RangeSet(T)
  include Enumerable(T)

  def initialize(range : Enumerable(T))
    @first = RangeNode(T).new(range.min, range.max)
  end

  def initialize
    @first = nil
  end

  def includes?(id : T) : Bool
    each_range do |r|
      if r.min <= id <= r.max
        return true
      end
    end

    false
  end

  def <<(id : T) : self
    unless r = @first
      @first = RangeNode(T).new(id, id)
      return self
    end

    pred = nil
    while r
      if id < r.min
        if id &+ 1 == r.min
          if pred && pred.max &+ 2 == r.min
            pred.succ = r.succ
            pred.max = r.max
          else
            r.min = id
          end
        else
          if pred
            if pred.max &+ 1 == id
              pred.max = id
            else
              pred.succ = RangeNode(T).new(id, id, r)
            end
          else
            @first = RangeNode(T).new(id, id, r)
          end
        end

        return self
      elsif id <= r.max
        return self
      end

      pred = r
      r = r.succ
    end

    if pred
      if pred.max &+ 1 == id
        pred.max = id
        return self
      end

      pred.succ = RangeNode(T).new(id, id)
    end

    self
  end

  def delete(id : T) : Bool
    return false unless r = @first

    if id < r.min
      return false
    end
    pred = nil
    while r
      if r.min <= id <= r.max
        if r.min == r.max
          if pred
            pred.succ = r.succ
          else
            @first = r.succ
          end
        elsif id == r.min
          r.min = id &+ 1
        elsif id == r.max
          r.max = id &- 1
        else
          new_range = RangeNode(T).new(id &+ 1, r.max, r.succ)
          r.max = id &- 1
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

  def inspect(io : IO)
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
    nil
  end

  private class RangeNode(T)
    property_initializer min : T, max : T, succ : self? = nil
  end
end
