struct RangeSet(T)
  include Enumerable(T)

  getter ranges

  def initialize
    @ranges = [] of Range(T, T)
  end

  def initialize(*ranges : Range(T, T))
    @ranges = ranges.to_a
  end

  def initialize(*values : T)
    @ranges = [] of Range(T, T)
    values.each { |v| self << v }
  end

  def each(& : T ->) : Nil
    @ranges.each { |r| r.each { |n| yield n } }
  end

  def <<(value : T) : self
    unless last = @ranges[-1]?
      @ranges << (value..value)
      return self
    end

    last_end = last.end

    if value > last_end
      if value - 1 == last_end
        @ranges[-1] = (last.begin)..value
      else
        @ranges << (value..value)
      end

      return self
    end

    i = @ranges.bsearch_index { |r| r.begin >= value }.try &.pred || 0
    r = @ranges[i]
    return self if r.includes?(value)
    next_range = @ranges[i + 1]?
    return self if next_range && next_range.includes?(value)
    extend_this_range = r.end + 1 == value
    extend_next_range = next_range && next_range.begin - 1 == value

    if extend_this_range && extend_next_range
      @ranges[i, 2] = (r.begin)..(next_range.not_nil!.end)
    elsif extend_this_range
      @ranges[i] = (r.begin)..value
    elsif extend_next_range
      @ranges[i + 1] = value..(next_range.not_nil!.end)
    else
      @ranges.insert(i + 1, value..value)
    end

    self
  end

  def self.[](*numbers : T) : RangeSet(T)
    set = RangeSet(T).new
    numbers.each { |n| set << n }
    set
  end

  def add(value : T) : Bool
    old = size
    self << value
    size > old
  end

  def includes?(value : T) : Bool
    !!@ranges.bsearch do |r|
      a = value <=> r.begin
      if a == 1
        b = value <=> r.end
        b == -1 ? 0 : b
      else
        a
      end
    end
  end

  def first : T
    @ranges[0]?.try &.begin || raise EmptyError.new
  end

  def last : T
    @ranges[-1]?.try &.end || raise EmptyError.new
  end

  def clear : self
    @ranges.clear
    self
  end

  def first_free : T
    (first = @ranges[0]?) ? first.begin > 0 ? 0 : first.end + 1 : T.zero
  end

  def size : Int32
    @ranges.sum &.size
  end

  # The number of numbers it would take to unify all the ranges into one.
  def holes
    holes = 0
    @ranges.each_with_index do |r1, i|
      if r2 = @ranges[i + 1]?
        holes += r2.begin - r1.end - 1
      end
    end
    holes
  end

  def delete(value) : T?
    i = @ranges.bsearch_index { |r| r.begin >= value || r.end >= value }
    return unless i
    range = @ranges[i]
    return unless range.includes?(value)

    case
    when range.size == 1
      @ranges.delete_at(i)
    when range.begin == value
      @ranges[i] = (value + 1)..(range.end)
    when range.end == value
      @ranges[i] = (range.begin)..(value - 1)
    else
      @ranges[i] = (range.begin)..(value - 1)
      @ranges.insert(i + 1, (value + 1)..(range.end))
    end

    value
  end

  def empty? : Bool
    @ranges.empty?
  end

  def inspect : Nil
    "RangeSet {#{@ranges.map { |r| r.size > 1 ? r : r.end }.join(", ")}}"
  end
end
