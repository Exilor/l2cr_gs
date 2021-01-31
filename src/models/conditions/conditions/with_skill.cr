class Condition
  class WithSkill < self
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !!skill == @val
    end
  end
end
