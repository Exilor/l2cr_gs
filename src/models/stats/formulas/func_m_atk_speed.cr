class FuncMAtkSpeed < AbstractFunction
  private def initialize
    super(Stats::MAGIC_ATTACK_SPEED)
  end

  def calc(effector, effected, skill, init_val)
    init_val * BaseStats::WIT.calc_bonus(effector)
  end

  INSTANCE = new
end
