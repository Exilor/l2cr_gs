struct Enum
  def self.[](arg : Int) : self
    from_value(arg)
  end

  def self.[]?(arg : Int) : self?
    from_value?(arg)
  end

  def self.size : Int32
    {{@type.constants.size}}
  end

  def mask : UInt32
    1u32 << to_i
  end

  def self.mask : UInt64
    (1u64 << size) - 1
  end
end
