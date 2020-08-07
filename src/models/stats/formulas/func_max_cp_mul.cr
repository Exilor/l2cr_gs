class FuncMaxCpMul < AbstractFunction
  private def initialize
    super(Stats::MAX_CP)
  end

  def calc(effector, effected, skill, value)
    value * BaseStats::CON.calc_bonus(effector)
  end

  INSTANCE = new
end
