class Condition
  class PlayerSouls < self
    initializer souls : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player
      pc.charged_souls >= @souls
    end
  end
end
