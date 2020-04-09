module Indexable(T)
  def sample(random = Random::DEFAULT, & : -> U) : T | U forall U
    if size == 0
      return yield
    elsif size == 1
      # Faster (x1.46) especially with Random::Secure (x301.56) on indexables
      # with only 1 element with negligible penalty for the rest
      return unsafe_fetch(0)
    end

    unsafe_fetch(random.rand(size))
  end

  def sample(random = Random::DEFAULT) : T
    sample(random) { raise IndexError.new }
  end

  def sample?(random = Random::DEFAULT) : T?
    sample(random) { nil }
  end

  def to_slice : Slice(T)
    Slice(T).new(size) { |i| unsafe_fetch(i) }
  end

  def bincludes?(val) : Bool
    bsearch { |n| n >= val } == val
  end

  def bsearch(obj : T) : Int32
    if ret = bsearch_index { |value| value >= obj }
      if obj == unsafe_fetch(ret)
        return ret
      end
    end

    -1
  end
end
