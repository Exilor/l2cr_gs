class FuncMaxMpMul < AbstractFunction
  private def initialize
    super(Stats::MAX_MP)
  end

  def calc(effector, effected, skill, value)
    value * BaseStats::MEN.calc_bonus(effector)
  end

  INSTANCE = new
end
