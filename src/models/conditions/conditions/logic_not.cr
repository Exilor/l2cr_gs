class Condition
  class LogicNot < self
    initializer condition : Condition

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !@condition.test(effector, effected, skill, item)
    end
  end
end
