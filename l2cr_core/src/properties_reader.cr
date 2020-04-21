require "./stats_set"

struct PropertiesReader
  @stats_set = StatsSet.new

  forward_missing_to @stats_set

  def parse(path : String)
    clear

    File.each_line(path) do |line|
      next if line.starts_with?('#')
      next unless line.includes?('=')
      key, value = line.split('=')
      key = key.strip
      value = value.strip
      self[key] = value
    end

    self
  end

  def get_string_array(key, default = [] of String) : Array(String)
    if value = self[key]
      return default.map &.to_s if value.empty?
      value.split(/;|,/)
    else
      if default.is_a?(String)
        default.split(/;|,/)
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
    value = self[key]
    hash = {} of Int32 => Int32
    value.split(';') do |pair|
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
    value = self[key]
    value = default.to_s unless value.is_a?(String) && !value.empty?

    hash = {} of Int32 => Float64
    value.split(',').each_with_index { |v, i| hash[i] = v.to_f }
    hash
  end

  def get_i32_float_assoc(key, *default) # '57,20' -> {57 => 20}
    value = self[key]
    value = default.to_s unless value.is_a?(String) && !value.empty?
    ret = {} of Int32 => Float64
    value.split(';') do |pair|
      temp = pair.split(',')
      ret[temp[0].to_i32] = temp[1].to_f64
    end
    ret
  end
end
