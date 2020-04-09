struct EnumMap(K, V)
  include Enumerable({K, V})

  private class Undefined
    INSTANCE = new
  end

  def initialize
    # Depending on require order, an EnumMap could be created before the enum's
    # members are created.
    unless K.size > 0
      raise "#{K} size cannot be 0"
    end
    @data = Pointer(V | Undefined).malloc(K.size, Undefined::INSTANCE)
  end

  def each#(&block : K, V ->) : Nil
    K.size.times do |i|
      k = K[i]
      v = @data[k.to_i]
      unless v.is_a?(Undefined)
        yield({k, v})
      end
    end
  end

  def each_value
    each do |k, v|
      yield v
    end
  end

  def each_key
    each do |k, v|
      yield k
    end
  end

  def []=(k : K, v : V)
    @data[k.to_i] = v
  end

  def fetch(k : K)
    val = @data[k.to_i]
    val.is_a?(Undefined) ? yield : val
  end

  def fetch(k : K) : V
    fetch(k) { raise KeyError.new("Missing EnumMap key: #{k.inspect}") }
  end

  def fetch(k : K, default)
    fetch(k) { default }
  end

  def [](k : K) : V
    fetch(k)
  end

  def []?(k : K) : V?
    fetch(k, nil)
  end

  def delete(k : K) : V?
    val = @data[k.to_i]
    @data[k.to_i] = Undefined::INSTANCE
    val.is_a?(Undefined) ? yield : val
  end

  def delete(k : K)
    delete(k) { nil }
  end

  def delete_if
    each do |k, v|
      if yield k, v
        delete(k)
      end
    end
  end

  def empty?
    each do |k, v|
      return false
    end

    true
  end

  def keys
    keys = [] of K
    each_key { |k| keys << k }
    keys
  end

  def values
    values = [] of V
    each_value { |v| values << v }
    values
  end

  def values_at(*keys : K)
    keys.map { |k| self[k] }
  end

  def key_index(key)
    each_with_index do |(my_key, my_value), index|
      return index if key == my_key
    end
    nil
  end

  def merge(other : Hash(L, W) | self) forall L, W
    hash = EnumMap(K | L, V | W).new
    hash.merge!(self)
    hash.merge!(other)
    hash
  end

  def merge(other : Hash(L, W) | self, &block : K, V, W -> V | W) forall L, W
    hash = EnumMap(K | L, V | W).new
    hash.merge!(self)
    hash.merge!(other) { |k, v1, v2| yield k, v1, v2 }
    hash
  end

  def merge!(other : Hash | self)
    other.each do |k, v|
      self[k] = v
    end
    self
  end

  def merge!(other : Hash | self, &block)
    other.each do |k, v|
      if self.has_key?(k)
        self[k] = yield k, self[k], v
      else
        self[k] = v
      end
    end
    self
  end

  def select(&block : K, V -> _)
    reject { |k, v| !yield(k, v) }
  end

  def select!(&block : K, V -> _)
    reject! { |k, v| !yield(k, v) }
  end

  def reject(&block : K, V -> _)
    each_with_object(EnumMap(K, V).new) do |(k, v), memo|
      memo[k] = v unless yield k, v
    end
  end

  def reject!(&block : K, V -> _)
    ret = nil
    each do |key, value|
      if yield(key, value)
        delete(key)
        ret = self
      end
    end
    ret
  end

  def reject(*keys)
    map = dup
    map.reject!(*keys)
  end

  def reject!(keys : Enumerable)
    keys.each { |k| delete(k) }
    self
  end

  def reject!(*keys)
    reject!(keys)
  end

  def select(keys : Enumerable | Tuple)
    hash = EnumMap(K, V).new
    keys.each { |k| hash[k] = self[k] if has_key?(k) }
    hash
  end

  def select(*keys)
    self.select(keys)
  end

  def select!(keys : Enumerable)
    each { |k, v| delete(k) unless keys.includes?(k) }
    self
  end

  def select!(*keys)
    select!(keys)
  end

  def compact
    ret = EnumMap(K, typeof(self[K[0]])).new
    each_with_object(ret) do |(key, value), memo|
      memo[key] = value unless value.nil?
    end
  end

  def clear
    K.size.times { |i| @data[i] = Undefined::INSTANCE }
  end

  def transform_keys(&block : K -> K2) forall K2
    each_with_object({} of K2 => V) do |(key, value), memo|
      memo[yield(key)] = value
    end
  end

  def transform_values(&block : V -> V2) forall V2
    each_with_object(EnumMap(K, V2).new) do |(key, value), memo|
      memo[key] = yield(value)
    end
  end

  def transform_values!(&block : V -> V)
    each do |k, v|
      self[k] = yield v
    end
  end

  def ==(other : self)
    LibC.memcmp(@data, other.@data, K.size) == 0
  end

  def self.zip(ary1 : Enumerable(K), ary2 : Enumerable(V))
    hash = EnumMap(K, V).new
    ary1.each_with_index do |key, i|
      hash[key] = ary2[i]
    end
    hash
  end

  def has_value?(val)
    each_value do |value|
      return true if value == val
    end
    false
  end

  def dig?(key : K, *subkeys)
    if (value = self[key]?) && value.responds_to?(:dig?)
      value.dig?(*subkeys)
    end
  end

  def dig?(key : K)
    self[key]?
  end

  def has_key?(key) : Bool
    return false unless key.is_a?(K)
    !@data[key.to_i].is_a?(Undefined)
  end

  def dig(key : K, *subkeys)
    if (value = self[key]) && value.responds_to?(:dig)
      return value.dig(*subkeys)
    end
    raise KeyError.new "EnumMap value not diggable for key: #{key.inspect}"
  end

  def key_for(value)
    key_for(value) { raise KeyError.new "Missing EnumMap key for value: #{value}" }
  end

  def key_for?(value)
    key_for(value) { nil }
  end

  def key_for(value)
    each do |k, v|
      return k if v == value
    end
    yield value
  end

  def hash(hasher)
    result = hasher.result

    each do |key, value|
      copy = hasher
      copy = key.hash(copy)
      copy = value.hash(copy)
      result += copy.result
    end

    result.hash(hasher)
  end
  # consider using memcpy instead
  def dup
    map = EnumMap(K, V).new
    each do |k, v|
      map[k] = v
    end
    map
  end

  def clone
    map = EnumMap(K, V).new
    each do |k, v|
      map[k] = v.clone
    end
    map
  end

  def to_h : Hash(K, V)
    h = {} of K => V
    each do |k, v|
      h[k] = v
    end
    h
  end

  def inspect(io : IO)
    io << "EnumMap("
    K.inspect(io)
    io << ", "
    V.inspect(io)
    io << ") {"
    found_one = false
    each do |key, value|
      io << ", " if found_one
      key.inspect(io)
      io << " => "
      value.inspect(io)
      found_one = true
    end
    io << "}"
  end
end
