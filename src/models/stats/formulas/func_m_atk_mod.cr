class FuncMAtkMod < AbstractFunction
  private def initialize
    super(Stats::MAGIC_ATTACK)
  end

  def calc(effector, effected, skill, value)
    lvl_mod = BaseStats::INT.calc_bonus(effector)
    int_mod = effector.level_mod
    value * Math.pow(lvl_mod, 2) * Math.pow(int_mod, 2)
  end

  INSTANCE = new
end
