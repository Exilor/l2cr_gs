struct Bool
  def self.new(str : String)
    if str.compare("true", true) == 0
      true
    elsif str.compare("false", true) == 0
      false
    else
      raise ArgumentError.new("Invalid value for Bool: #{str}")
    end
  end
end
