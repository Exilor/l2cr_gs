require "./inventory"

class Condition
  class SlotItemType < Inventory
    def initialize(slot : Int32, mask : Int32)
      super(slot)
      @mask = mask
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless effector.player?
      item_slot = effector.inventory[@slot]
      return false unless item_slot
      item_slot.template.item_mask & @mask != 0
    end
  end
end
