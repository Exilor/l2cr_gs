struct Slice(T)
  def +(other : self) : self
    new_size = size + other.size
    ptr = Pointer(T).malloc(new_size)
    slice = Slice(T).new(ptr, new_size)
    copy_to(slice)
    other.copy_to(slice + other.size)
    slice
  end

  def add(*values : T) : self
    total_size = size + values.size
    ptr = Pointer(T).malloc(total_size)
    ptr.copy_from(to_unsafe, size)
    values.each_with_index do |val, i|
      ptr[size + i] = val
    end
    ptr.to_slice(total_size)
  end
end
