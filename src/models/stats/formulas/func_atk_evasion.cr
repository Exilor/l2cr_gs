class FuncAtkEvasion < AbstractFunction
  private def initialize
    super(Stats::EVASION_RATE)
  end

  def calc(effector : L2Character, effected : L2Character?, skill : Skill?, value : Float64) : Float64
    level = effector.level
    if effector.player?
      value += (Math.sqrt(effector.dex) * 6) + level
      diff = (level &- 69).to_f
      if level >= 78
        diff *= 1.2
      end

      if level >= 70
        value += diff
      end
    else
      value += (Math.sqrt(effector.dex) * 6) + level
      if level > 69
        value += level &- 69 &+ 2
      end
    end

    value.trunc
  end

  INSTANCE = new
end
