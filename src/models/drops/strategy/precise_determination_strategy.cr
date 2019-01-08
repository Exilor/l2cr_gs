struct PreciseDeterminationStrategy
  private def initialize(&@proc : IDropItem -> Bool)
  end

  def precise_calculated?(item : IDropItem) : Bool
    @proc.call(item)
  end

  ALWAYS  = new { |drop_item| true }
  DEFAULT = new { |drop_item| Config.precise_drop_calculation }
  NEVER   = new { |drop_item| false }

  def self.parse(name : String) : self
    case name.casecmp
    when "always"
      ALWAYS
    when "default"
      DEFAULT
    when "never"
      NEVER
    else
      raise "unknown #{self} #{name.inspect}"
    end
  end
end
