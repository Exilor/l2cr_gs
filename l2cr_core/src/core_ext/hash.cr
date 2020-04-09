class Hash(K, V)
  def put_if_absent(key : K, & : -> V)
    self[key] ||= yield
  end

  def find_value : V?
    each_value { |v| return v if yield v }
    nil
  end

  def values_slice : Slice(V)
    idx = 0
    ptr = Pointer(V).malloc(size)
    each_value do |value|
      ptr[idx] = value
      idx += 1
    end
    Slice.new(ptr, size)
  end

  def keys_slice : Slice(K)
    idx = 0
    ptr = Pointer(K).malloc(size)
    each_key do |value|
      ptr[idx] = value
      idx += 1
    end
    Slice.new(ptr, size)
  end

  def select_values(& : V ->) : Array(V)
    ret = [] of V
    each_value { |v| ret << v if yield v }
    ret
  end

  struct LocalEntryIterator(K, V)
    include BaseIterator
    include Iterator({K, V})

    @hash : Hash(K, V)
    # @current : Entry(K, V)?
    @index : Int32

    def next
      base_next { |entry| {entry.key, entry.value} }
    end

    def size
      @hash.size
    end
  end

  def local_each
    LocalEntryIterator(K, V).new(self)
  end

  private struct LocalKeyIterator(K, V)
    include BaseIterator
    include Iterator(K)

    @hash : Hash(K, V)
    @index : Int32

    def next
      base_next &.key
    end

    def size
      @hash.size
    end
  end

  def local_each_key
    LocalKeyIterator(K, V).new(self)
  end

  private struct LocalValueIterator(K, V)
    include BaseIterator
    include Iterator(V)

    @hash : Hash(K, V)
    @index : Int32

    def next
      base_next &.value
    end

    def size
      @hash.size
    end
  end

  def local_each_value
    LocalValueIterator(K, V).new(self)
  end
end
