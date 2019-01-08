class Condition
  class PlayerSex < Condition
    initializer sex: Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player?
      (pc.appearance.sex ? 1 : 0) == @sex
    end
  end
end
