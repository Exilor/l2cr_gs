class Condition
  class PlayerGrade < Condition
    initializer value : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player
      @value == pc.expertise_level
    end
  end
end
