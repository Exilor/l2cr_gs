class FuncMAtkCritical < AbstractFunction
  private def initialize
    super(Stats::MCRITICAL_RATE)
  end

  def calc(effector : L2Character, effected : L2Character?, skill : Skill?, value : Float64) : Float64
    if !effector.player? || effector.active_weapon_instance
      return value * BaseStats::WIT.calc_bonus(effector) * 10
    end

    value
  end

  INSTANCE = new
end
