class L2IdSet < RangeSet(Int32)
  def first_free : Int32
    unless first = @first
      return 0
    end

    first.max &+ 1
  end

  def take_first_id : Int32
    # handle the case where all ids are free
    unless first = @first
      @first = RangeNode.new(0, 0)
      return 0
    end

    # the first free id is the next id of the first range's end
    id = first.max &+ 1

    # update the first range and return if it's the only range
    unless second = first.succ
      first.max = id
      return id
    end

    # merge the first and second ranges if they were 1 id apart from being
    # a single range
    if second.min &- 1 == id
      first.succ = second.succ
      first.max = second.max
    else # otherwise update the fist range
      first.max = id
    end

    id
  end

  def ranges
    ret = [] of Range(Int32, Int32)
    each_range { |r| ret << (r.min..r.max) }
    ret
  end
end
