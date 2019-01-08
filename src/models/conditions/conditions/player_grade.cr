class Condition
  class PlayerGrade < Condition
    initializer value: Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !!effector.acting_player? &&
      @value == effector.acting_player.expertise_level
    end
  end
end
