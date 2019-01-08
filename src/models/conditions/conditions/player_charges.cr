class Condition
  class PlayerCharges < Condition
    initializer charges: Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      !!effector.acting_player? &&
      effector.acting_player.charges >= @charges
    end
  end
end
