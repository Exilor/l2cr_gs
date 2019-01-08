class FuncPAtkMod < AbstractFunction
  private def initialize
    super(Stats::POWER_ATTACK)
  end

  def calc(effector, effected, skill, init_val)
    init_val * BaseStats::STR.calc_bonus(effector) * effector.level_mod
  end

  INSTANCE = new
end
