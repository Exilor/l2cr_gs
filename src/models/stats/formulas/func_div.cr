class FuncDiv < AbstractFunction
  def calc(effector, effected, skill, value)
    if test(effector, effected, skill) && @value != 0
      return value / @value
    end

    value
  end
end
