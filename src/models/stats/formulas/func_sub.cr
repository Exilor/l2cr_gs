class FuncSub < AbstractFunction
  def calc(effector, effected, skill, value)
    test(effector, effected, skill) ? value - @value : value
  end
end
