class FuncMAtkMod < AbstractFunction
  private def initialize
    super(Stats::MAGIC_ATTACK)
  end

  def calc(effector, effected, skill, value)
    effector = effector.acting_player if effector.player?
    lvl_mod = BaseStats::INT.calc_bonus(effector)
    int_mod = effector.level_mod
    value * (lvl_mod ** 2) * (int_mod ** 2)
  end

  INSTANCE = new
end
