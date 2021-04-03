class FuncPAtkSpeed < AbstractFunction
  private def initialize
    super(Stats::POWER_ATTACK_SPEED)
  end

  def calc(effector : L2Character, effected : L2Character?, skill : Skill?, value : Float64) : Float64
    value * BaseStats::DEX.calc_bonus(effector)
  end

  INSTANCE = new
end
