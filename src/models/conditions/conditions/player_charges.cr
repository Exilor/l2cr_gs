class Condition
  class PlayerCharges < self
    initializer charges : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player
      pc.charges >= @charges
    end
  end
end
