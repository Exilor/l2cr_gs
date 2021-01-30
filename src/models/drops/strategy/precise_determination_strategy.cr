struct PreciseDeterminationStrategy
  private def initialize(&@proc : IDropItem -> Bool)
  end

  def precise_calculated?(item : IDropItem) : Bool
    @proc.call(item)
  end

  ALWAYS  = new { |_| true }
  DEFAULT = new { |_| Config.precise_drop_calculation }
  NEVER   = new { |_| false }
end
