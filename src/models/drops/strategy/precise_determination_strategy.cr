struct PreciseDeterminationStrategy
  private def initialize(&@proc : IDropItem -> Bool)
  end

  def precise_calculated?(item : IDropItem) : Bool
    @proc.call(item)
  end

  ALWAYS  = new { |drop_item| true }
  DEFAULT = new { |drop_item| Config.precise_drop_calculation }
  NEVER   = new { |drop_item| false }
end
