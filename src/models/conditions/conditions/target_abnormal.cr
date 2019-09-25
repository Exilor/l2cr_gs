class Condition
  class TargetAbnormal < Condition
    initializer abnormal_id : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !!effected && (effected.abnormal_visual_effects & @abnormal_id != 0)
    end
  end
end
