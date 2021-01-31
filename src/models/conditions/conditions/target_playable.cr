class Condition
  class TargetPlayable < self
    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      effected.is_a?(L2Playable)
    end
  end
end
