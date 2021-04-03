class FuncMaxHpMul < AbstractFunction
  private def initialize
    super(Stats::MAX_HP)
  end

  def calc(effector : L2Character, effected : L2Character?, skill : Skill?, value : Float64) : Float64
    value * BaseStats::CON.calc_bonus(effector)
  end

  INSTANCE = new
end
