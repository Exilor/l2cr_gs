class Condition
  class PlayerHasPet < Condition
    @item_ids : Slice(Int32)?

    def initialize(item_ids : Slice(Int32))
      unless item_ids.size == 1 && item_ids[0] == 0
        @item_ids = item_ids.sort!
      end
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effected.try &.acting_player
      return false unless pet = pc.summon.as?(L2PetInstance)
      return true unless item_ids = @item_ids
      return false unless control_item = pet.control_item
      item_ids.bincludes?(control_item.id)
    end
  end
end
