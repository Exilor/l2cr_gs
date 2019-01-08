class FuncAtkCritical < AbstractFunction
  private def initialize
    super(Stats::CRITICAL_RATE)
  end

  def calc(effector, effected, skill, init_val)
    init_val * BaseStats::DEX.calc_bonus(effector) * 10
  end

  INSTANCE = new
end
