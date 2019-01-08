class StatsSet
  private alias ValueType = Number::Primitive | String | Bool | Array(String) | Array(Bool) | SkillHolder | Array(MinionHolder) | L2Object

  def initialize
    @hash = {} of String => ValueType
  end

  def initialize(attrs : XML::Attributes)
    @hash = Hash(String, ValueType).new(attrs.size)
    merge(attrs)
  end

  def merge(attrs : XML::Attributes)
    attrs.each { |node| @hash[node.name] = node.text }
  end

  def merge(arg)
    arg.each { |k, v| self[k] = v }
  end

  def parse(path : String)
    clear
    File.each_line(path) do |line|
      next if line.starts_with?('#')
      next unless line.includes?('=')
      key, value = line.split('=')
      key = key.strip
      value = value.strip
      @hash[key] = value
    end

    self
  end

  def []=(key : String, value : ValueType?)
    @hash[key] = value unless value.nil?
  end

  def [](key)
    @hash[key]
  end

  def []?(key)
    @hash[key]?
  end

  def has_key?(k)
    @hash.has_key?(k)
  end

  def delete(k)
    @hash.delete(k)
  end

  def clear
    @hash.clear
    self
  end

  def empty?
    @hash.empty?
  end

  def size
    @hash.size
  end

  def each
    @hash.each { |k, v| yield k, v }
  end

  def each_key
    @hash.each_key { |k| yield k }
  end

  # def get_u8(key : String)
  #   value = @hash[key]
  #
  #   if value.responds_to?(:to_u8)
  #     value.to_u8
  #   else
  #     raise "Invalid value for get_u8: #{value}:#{value.class}"
  #   end
  # end
  #
  # def get_u8(key : String, default)
  #   value = @hash.fetch(key) { return default.to_u8 }
  # end

  def add(node, name, internal = name)
    if val = node[internal]?
      self[name] = val
    end
  end

  {% for name in %w(i8 i16 i32 i64 u8 u16 u32 u64 f32 f64) %}
    {% prefix = name.starts_with?('i') ? "Int".id : (name.starts_with?('u') ? "UInt".id : "Float".id) %}
    {% type = "#{prefix}#{name[1..-1].id}".id %}

    def get_{{name.id}}(key : String) : {{type}}
      value = @hash.fetch(key) { raise KeyError.new("Missing key: #{key.inspect}") }

      if value.nil?
        raise KeyError.new("Nil value for key #{key.inspect}")
      end

      if value.responds_to?(:to_{{name.id}})
        if value.is_a?(String)
          value.to_{{name.id}}(strict: false)
        else
          value.to_{{name.id}}
        end
      else
        raise "Invalid value for get_{{name.id}}: #{value.inspect}:#{value.class}"
      end
    end

    def get_{{name.id}}(key : String, default) : {{type}}
      value = @hash.fetch(key) { return default.to_{{name.id}} }
      if value.responds_to?(:to_{{name.id}})
        if value.is_a?(String)
          value.to_{{name.id}}(strict: false)
        else
          value.to_{{name.id}}
        end
      else
        raise "Invalid value for get_{{name.id}}: #{value.inspect}:#{value.class}"
      end
    end
  {% end %}

  def get_bool(key : String)
    value = @hash.fetch(key) { raise KeyError.new("Missing key: #{key.inspect}") }

    if value.nil?
      raise KeyError.new("Nil value for key #{key.inspect}")
    end

    if value.is_a?(Bool)
      value
    elsif value.is_a?(String)
      if value.compare("true", true) == 0
        true
      elsif value.compare("false", true) == 0
        false
      else
        raise "Invalid value for get_bool: #{value.inspect}"
      end
    else
      raise "Invalid value for get_bool: #{value.inspect}:#{value.class}"
    end
  end

  def get_bool(key : String, default : Bool)
    value = @hash.fetch(key) { return default }

    if value.nil?
      raise KeyError.new("Nil value for key #{key.inspect}")
    end

    if value.is_a?(Bool)
      value
    elsif value.is_a?(String)
      if value.compare("true", true) == 0
        true
      elsif value.compare("false", true) == 0
        false
      else
        raise "Invalid value for get_bool: #{value.inspect}"
      end
    else
      raise "Invalid value for get_bool: #{value.inspect}:#{value.class}"
    end
  end

  def get_string(key : String) : String
    value = @hash[key]
    unless value.is_a?(String)
      raise "Invalid value for get_string: #{value.inspect}:#{value.class}"
    end
    value
  end

  def get_string(key : String, default)
    value = @hash[key]?
    if value.is_a?(String)
      value
    elsif value.nil?
      default
    else
      raise "Invalid value for get_string: #{value.inspect}:#{value.class}"
    end
  end

  def get_regex(key : String) : Regex
    value = @hash[key]
    case value
    when Regex
      value
    when String
      /#{value}/
    else
      raise "Invalid value for get_regex: #{value.inspect}:#{value.class}"
    end
    value
  end

  def get_regex(key : String, default)
    value = @hash[key]?
    case value
    when Regex
      value
    when String
      /#{value}/
    when nil
      default
    else
      raise "Invalid value for get_regex: #{value.inspect}:#{value.class}"
    end
  end



  def get_enum(key : String, enum_class : T.class) forall T
    value = @hash.fetch(key) { raise KeyError.new("Missing key: #{key.inspect}") }

    if value.nil?
      raise KeyError.new("Nil value for key #{key.inspect}")
    end

    if value.is_a?(String)
      enum_class.parse(value)
    else
      raise "Invalid value for get_enum: #{value.inspect}:#{value.class}"
    end
  end

  def get_enum(key : String, enum_class : T.class, default : T?) forall T
    value = @hash.fetch(key) { return default }

    if value.nil?
      raise KeyError.new("Nil value for key #{key.inspect}")
    end

    if value.is_a?(String)
      enum_class.parse(value)
    else
      raise "Invalid value for get_enum: #{value.inspect}:#{value.class}"
    end
  end

  def get_enum(key : String, enum_class : T.class, default : String) forall T
    get_enum(key, enum_class) || enum_class.parse(default)
  end

  def get_object(key : String, klass : T.class) forall T
    @hash[key].as(T)
  end

  def get_object(key : String, klass : T.class, default) forall T
    @hash.fetch(key, default).as(T)
  end

  def get_string_array(key, default = [] of String) : Array(String)
    if value = @hash[key]
      return value if value.is_a?(Array(String))
      unless value.is_a?(String)
        raise "Invalid value for get_string_array: #{value.inspect}:#{value.class}"
      end
      return default.map &.to_s if value.empty?
      value.split(value.includes?(';') ? ';' : ',')
    else
      if default.is_a?(String)
        default.split(default.includes?(';') ? ';' : ',')
      else
        if default.is_a?(Array(String))
          default
        else
          default.map &.to_s
        end
      end
    end
  end

  def get_i32_array(key, default = [] of String)
    get_string_array(key, default).map &.to_i
  end

  def get_i32_hash(key, *default)
    value = @hash[key]
    return value if value.is_a?(Hash)
    unless value.nil? || value.is_a?(String)
      raise "Invalid value for get_string_array: #{value.inspect}:#{value.class}"
    end
    value = default.to_s if value.nil? || value.empty?
    hash = {} of Int32 => Int32
    value.split(';').each do |pair|
      pair = pair.split(',').map &.to_i
      raise IndexError.new("malformed int hash") unless pair.size == 2
      hash[pair[0]] = pair[1]
    end
    hash
  end

  def get_i32_assoc(key, *default)
    value = get_i32_hash(key, *default)
    value.to_a.map(&.to_a.to_slice).to_slice
  end

  def get_i32_float_hash(key, *default) # '57,20' -> {0 => 57, 1 => 20}
    value = @hash[key]
    return value if value.is_a?(Hash)
    value = default.to_s unless value.is_a?(String) && !value.empty?

    hash = {} of Int32 => Float64
    value.split(',').each_with_index { |v, i| hash[i] = v.to_f }
    hash
  end

  def get_i32_float_assoc(key, *default) # '57,20' -> {57 => 20}
    value = @hash[key]
    return value if value.is_a?(Hash)
    value = default.to_s unless value.is_a?(String) && !value.empty?
    # value.split(';').map { |pair| [pair.split(',')[0].to_i, pair.split(',')[1].to_f] }.to_h
    ret = {} of Int32 => Float64
    value.split(';').each do |pair|
      temp = pair.split(',')
      ret[temp[0].to_i32] = temp[1].to_f64
    end
    ret
  end

  def get_minion_list(key : String)
    @hash[key]?.as?(Array(MinionHolder)) || Slice(MinionHolder).empty
  end

  EMPTY = new
end
