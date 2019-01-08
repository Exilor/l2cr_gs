class FuncDiv < AbstractFunction
  def calc(effector, effected, skill, val)
    test(effector, effected, skill) ? @value != 0 ? val / @value : val : val
  end
end
