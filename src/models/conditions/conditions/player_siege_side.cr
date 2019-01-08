class Condition
  class PlayerSiegeSide < Condition
    initializer side: Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player?
      pc.siege_side == @side
    end
  end
end
