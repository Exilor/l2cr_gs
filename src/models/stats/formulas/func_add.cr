class FuncAdd < AbstractFunction
  def calc(effector, effected, skill, val)
    test(effector, effected, skill) ? val + @value : val
  end
end
