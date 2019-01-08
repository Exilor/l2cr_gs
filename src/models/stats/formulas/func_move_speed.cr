class FuncMoveSpeed < AbstractFunction
  private def initialize
    super(Stats::MOVE_SPEED)
  end

  def calc(effector, effected, skill, value)
    value * BaseStats::DEX.calc_bonus(effector)
  end

  INSTANCE = new
end
