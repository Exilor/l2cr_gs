class FuncMAtkCritical < AbstractFunction
  private def initialize
    super(Stats::MCRITICAL_RATE)
  end

  def calc(effector, effected, skill, init_val)
    if !effector.player? || effector.active_weapon_instance?
      init_val * BaseStats::WIT.calc_bonus(effector) * 10
    else
      init_val
    end
  end

  INSTANCE = new
end
