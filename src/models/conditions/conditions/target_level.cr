class Condition
  class TargetLevel < self
    initializer level : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !!effected && effected.level >= @level
    end
  end
end
