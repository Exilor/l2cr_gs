class FuncPAtkMod < AbstractFunction
  private def initialize
    super(Stats::POWER_ATTACK)
  end

  def calc(effector, effected, skill, value)
    value * BaseStats::STR.calc_bonus(effector) * effector.level_mod
  end

  INSTANCE = new
end
