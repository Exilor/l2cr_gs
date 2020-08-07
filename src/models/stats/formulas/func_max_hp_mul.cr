class FuncMaxHpMul < AbstractFunction
  private def initialize
    super(Stats::MAX_HP)
  end

  def calc(effector, effected, skill, value)
    value * BaseStats::CON.calc_bonus(effector)
  end

  INSTANCE = new
end
