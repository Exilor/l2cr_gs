class FuncSet < AbstractFunction
  def calc(effector : L2Character, effected : L2Character?, skill : Skill?, value : Float64) : Float64
    test(effector, effected, skill) ? @value : value
  end
end
