class Condition
  class PlayerPkCount < self
    initializer pk : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player
      pc.pk_kills <= @pk
    end
  end
end
