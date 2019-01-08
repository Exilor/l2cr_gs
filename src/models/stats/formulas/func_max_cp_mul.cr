class FuncMaxCpMul < AbstractFunction
  private def initialize
    super(Stats::MAX_CP)
  end

  def calc(effector, effected, skill, init_val)
    init_val * BaseStats::CON.calc_bonus(effector)
  end

  INSTANCE = new
end
