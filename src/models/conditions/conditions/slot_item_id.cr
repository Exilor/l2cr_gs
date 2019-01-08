require "./inventory"

class Condition
  class SlotItemId < Inventory
    def initialize(slot : Int32, @item_id : Int32, @enchant_level : Int32)
      super(slot)
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless effector.player?
      if item_slot = effector.inventory[@slot]
        item_slot.id == @item_id && item_slot.enchant_level >= @enchant_level
      else
        @item_id == 0
      end
    end
  end
end
