require "string_pool"

struct StatsSet
  include Enumerable({String, String})

  private POOL = StringPool.new

  def initialize(*args, **opts)
    @hash = Hash(String, String).new(*args, **opts)
  end

  def merge!(arg)
    arg.each { |k, v| self[k] = v }
  end

  def []=(key : String, value)
    return if value.nil?
    value = value.to_s
    key = POOL.get(key)
    value = POOL.get(value)
    @hash[key] = value
  end

  delegate :[], :[]?, has_key?, delete, clear, empty?, size, each, each_key,
    to: @hash

  {% for name in %w(i8 i16 i32 i64 u8 u16 u32 u64 f32 f64) %}
    {% prefix = name.starts_with?('i') ? "Int".id : (name.starts_with?('u') ? "UInt".id : "Float".id) %}
    {% type = "#{prefix}#{name[1..-1].id}".id %}

    def get_{{name.id}}(key : String) : {{type}}
      value = @hash[key]
      value.to_{{name.id}}(strict: false)
    end

    def get_{{name.id}}(key : String, default) : {{type}}
      value = @hash.fetch(key) { return default.to_{{name.id}} }
      value.to_{{name.id}}(strict: false)
    end
  {% end %}

  def get_bool(key : String) : Bool
    case value = @hash[key]
    when .casecmp?("true")
      true
    when .casecmp?("false")
      false
    else
      raise "Invalid value for get_bool: " + value
    end
  end

  def get_bool(key : String, default)
    case value = @hash.fetch(key) { return default }
    when .casecmp?("true")
      true
    when .casecmp?("false")
      false
    else
      raise "Invalid value for get_bool: " + value
    end
  end

  def get_string(key : String) : String
    @hash[key]
  end

  def get_string(key : String, default)
    @hash.fetch(key, default)
  end

  def get_regex(key : String) : Regex
    /#{get_string(key)}/
  end

  def get_regex(key : String, default)
    /#{get_string(key, default)}/
  end

  def get_enum(key : String, enum_class)
    enum_class.parse(get_string(key))
  end

  def get_enum(key : String, enum_class, default)
    enum_class.parse(@hash.fetch(key) { return default })
  end

  EMPTY = new
end
