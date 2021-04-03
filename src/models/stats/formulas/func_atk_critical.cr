class FuncAtkCritical < AbstractFunction
  private def initialize
    super(Stats::CRITICAL_RATE)
  end

  def calc(effector : L2Character, effected : L2Character?, skill : Skill?, value : Float64) : Float64
    value * BaseStats::DEX.calc_bonus(effector) * 10
  end

  INSTANCE = new
end
