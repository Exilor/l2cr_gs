class FuncMAtkCritical < AbstractFunction
  private def initialize
    super(Stats::MCRITICAL_RATE)
  end

  def calc(effector, effected, skill, value)
    if !effector.player? || effector.active_weapon_instance?
      value * BaseStats::WIT.calc_bonus(effector) * 10
    else
      value
    end
  end

  INSTANCE = new
end
