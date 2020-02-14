require "../../../enums/armor_type"

class Condition
  class UsingItemType < Condition
    @armor : Bool

    def initialize(@mask : Int32)
      @armor = (mask & (ArmorType::MAGIC.mask | ArmorType::LIGHT.mask | ArmorType::HEAVY.mask)) != 0
    end

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      unless effector.is_a?(L2PcInstance)
        return @armor ? false : @mask & effector.attack_type.mask != 0
      end

      inv = effector.inventory

      if @armor
        return false unless chest = inv.chest_slot
        chest_mask = chest.mask
        return false if @mask & chest_mask == 0
        chest_body_part = chest.body_part
        return true if chest_body_part == L2Item::SLOT_FULL_ARMOR
        return false unless legs = inv.legs_slot
        return @mask & legs.mask != 0
      end

      @mask & inv.mask != 0
    end
  end
end
