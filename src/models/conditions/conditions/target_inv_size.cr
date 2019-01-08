class Condition
  class TargetInvSize < Condition
    initializer size: Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      effected.is_a?(L2PcInstance) &&
      effected.inventory.get_size(false) <= effected.inventory_limit - @size
    end
  end
end
