class FuncPAtkMod < AbstractFunction
  private def initialize
    super(Stats::POWER_ATTACK)
  end

  def calc(effector : L2Character, effected : L2Character?, skill : Skill?, value : Float64) : Float64
    value * BaseStats::STR.calc_bonus(effector) * effector.level_mod
  end

  INSTANCE = new
end
