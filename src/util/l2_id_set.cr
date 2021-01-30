require "./range_set"

# A specialized RangeSet that can efficiently get the first available l2id.
class L2IdSet < RangeSet(Int32)
  def first_free : Int32
    (first = @first) ? first.max &+ 1 : 0
  end

  def take_first_id : Int32
    # Handle the case where all ids are free
    unless first = @first
      @first = RangeNode.new(0, 0)
      return 0
    end

    # The first free id is the next id of the first range's end
    id = first.max &+ 1

    # Update the first range and return if it's the only range
    unless second = first.succ
      first.max = id
      return id
    end

    # Merge the first and second ranges if they were 1 id apart from being
    # a single range
    if second.min &- 1 == id
      first.succ = second.succ
      first.max = second.max
    else # Otherwise update the fist range
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
