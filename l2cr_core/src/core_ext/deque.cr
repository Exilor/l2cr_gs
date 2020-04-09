class Deque(T)
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

  def safe_each : Nil
    # temp = Slice(T).new(size) { |i| unsafe_fetch(i) }
    # temp.each { |e| yield e }
    reverse_each { |e| yield e }
  end
end
