class Condition
  class TargetNone < Condition
    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      effected.nil?
    end
  end
end
