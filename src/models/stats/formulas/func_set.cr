class FuncSet < AbstractFunction
  def calc(effector, effected, skill, val)
    test(effector, effected, skill) ? @value : val
  end
end
