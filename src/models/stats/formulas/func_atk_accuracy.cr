class FuncAtkAccuracy < AbstractFunction
  private def initialize
    super(Stats::ACCURACY_COMBAT)
  end

  def calc(effector : L2Character, effected : L2Character?, skill : Skill?, value : Float64) : Float64
    level = effector.level
    value += (Math.sqrt(effector.dex) * 6) + level

    if level > 77
      value += level &- 76
    end

    if level > 69
      value += level &- 69
    end

    value
  end

  INSTANCE = new
end
