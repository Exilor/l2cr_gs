struct EnumSet(T)
  include Enumerable(T)

  def initialize(set : Bool = false)
    unless T.size > 0
      raise "Size of #{T} must be greater than 0"
    end
    @data = Pointer(Bool).malloc(T.size, set)
  end

  def initialize(args : Enumerable(T))
    unless T.size > 0
      raise "Size of #{T} must be greater than 0"
    end
    @data = Pointer(Bool).malloc(T.size, false)
    args.each { |a| self << a }
  end

  def self.[](*members : T)
    set = EnumSet(T).new
    members.each { |m| set << m }
    set
  end

  def each(&block : T ->) : Nil
    T.size.times do |i|
      yield T[i] if @data[i]
    end
  end

  def set_all
    T.size.times { |i| @data[i] = true }
    self
  end

  def empty? : Bool
    T.size.times { |i| return false if @data[i] }
    true
  end

  def <<(member : T)
    @data[member.to_i] = true
    self
  end

  def delete(member : T)
    @data[member.to_i] = false
    self
  end

  def includes?(member : T) : Bool
    @data[member.to_i]
  end

  def clear
    T.size.times { |i| @data[i] = false }
    self
  end

  def subtract(other : Enumerable(T))
    other.each do |m|
      delete(m)
    end
    self
  end

  def dup
    set = EnumSet(T).new
    set.@data.copy_from(@data, T.size)
    set
  end

  def -(other : Enumerable(T))
    set = EnumSet(T).new
    set.@data.copy_from(@data, T.size)
    other.each do |m|
      set.delete(m)
    end
    set
  end

  def concat(other : Enumerable(T))
    other.each do |m|
      @data[m.to_i] = true
    end
    self
  end

  def ==(other : self)
    LibC.memcmp(@data, other.@data, T.size) == 0
  end

  def to_s(io : IO)
    io << {{@type.stringify + " {"}}
    join(", ", io)
    io << '}'
  end

  def inspect(io : IO)
    to_s(io)
  end
end
