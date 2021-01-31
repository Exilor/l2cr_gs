class Condition
  class TargetWeight < self
    initializer weight : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      if pc = effected.as?(L2PcInstance)
        if !pc.diet_mode? && pc.max_load > 0
          w = ((pc.current_load - pc.bonus_weight_penalty) * 100) / pc.max_load
          return w < @weight
        end
      end

      false
    end
  end
end
