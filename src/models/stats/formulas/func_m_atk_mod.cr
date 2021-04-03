class FuncMAtkMod < AbstractFunction
  private def initialize
    super(Stats::MAGIC_ATTACK)
  end

  def calc(effector : L2Character, effected : L2Character?, skill : Skill?, value : Float64) : Float64
    lvl_mod = BaseStats::INT.calc_bonus(effector)
    int_mod = effector.level_mod
    value * Math.pow(lvl_mod, 2) * Math.pow(int_mod, 2)
  end

  INSTANCE = new
end
