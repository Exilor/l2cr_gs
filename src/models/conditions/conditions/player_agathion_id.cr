class Condition
  class PlayerAgathionId < Condition
    initializer agathion_id : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      pc = effector.acting_player
      !!pc && pc.agathion_id == @agathion_id
    end
  end
end
