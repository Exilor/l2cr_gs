class Condition
  class PlayerWeight < self
    initializer weight : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      pc = effector.acting_player
      if pc && pc.max_load > 0
        weight_proc = ((pc.current_load - pc.bonus_weight_penalty) * 100) / pc.max_load
        return weight_proc < @weight || pc.diet_mode?
      end

      true
    end
  end
end
