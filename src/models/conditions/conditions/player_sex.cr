class Condition
  class PlayerSex < Condition
    initializer sex : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player
      pc.appearance.sex == @sex
    end
  end
end
