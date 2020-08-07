class FuncSet < AbstractFunction
  def calc(effector, effected, skill, value)
    test(effector, effected, skill) ? @value : value
  end
end
