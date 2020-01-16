class Condition
  class PlayerInvSize < Condition
    initializer size : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      if pc = effector.acting_player
        return pc.inventory.get_size(false) <= pc.inventory_limit - @size
      end

      true
    end
  end
end
