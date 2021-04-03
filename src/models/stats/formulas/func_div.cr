class FuncDiv < AbstractFunction
  def calc(effector : L2Character, effected : L2Character?, skill : Skill?, value : Float64) : Float64
    if test(effector, effected, skill) && @value != 0
      return value / @value
    end

    value
  end
end
