class FuncMAtkCritical < AbstractFunction
  private def initialize
    super(Stats::MCRITICAL_RATE)
  end

  def calc(effector, effected, skill, value)
    if !effector.player? || effector.active_weapon_instance
      return value * BaseStats::WIT.calc_bonus(effector) * 10
    end

    value
  end

  INSTANCE = new
end
