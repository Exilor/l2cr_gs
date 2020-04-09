class Array(T)
  def safe_each(&block : T ->)
    reverse_each { |e| yield e }
  end

  def to_slice : Slice(T)
    ptr = Pointer(T).malloc(@size)
    ptr.copy_from(@buffer, @size)
    ptr.to_slice(@size)
  end

  def delete_first(elem)
    if idx = index(elem)
      delete_at(idx)
    end
  end

  def delete_last(elem)
    if idx = rindex(elem)
      delete_at(idx)
    end
  end

  def trim
    if @buffer && @capacity > @size && @size > 0
      @buffer = @buffer.realloc(@size)
      @capacity = @size
    end

    self
  end

  # def trim
  #   if @buffer && @capacity > @size && @size > 0
  #     (@buffer + @size).clear(@capacity - @size)
  #   end

  #   self
  # end
end
