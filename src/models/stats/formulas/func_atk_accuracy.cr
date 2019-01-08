class FuncAtkAccuracy < AbstractFunction
  private def initialize
    super(Stats::ACCURACY_COMBAT)
  end

  def calc(effector, effected, skill, init_val)
    level = effector.level

    value = init_val + (Math.sqrt(effector.dex * 6)) + level

    if level > 77
      value += level - 76
    end

    if level > 69
      value += level - 69
    end

    value
  end

  INSTANCE = new
end
