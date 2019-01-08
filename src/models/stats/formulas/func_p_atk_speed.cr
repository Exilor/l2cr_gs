class FuncPAtkSpeed < AbstractFunction
  private def initialize
    super(Stats::POWER_ATTACK_SPEED)
  end

  def calc(effector, effected, skill, init_val)
    init_val * BaseStats::DEX.calc_bonus(effector)
  end

  INSTANCE = new
end
