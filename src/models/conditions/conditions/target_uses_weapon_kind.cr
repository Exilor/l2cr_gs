class Condition
  class TargetUsesWeaponKind < Condition
    initializer weapon_mask: Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless effected
      return false unless wpn = effected.active_weapon_item?
      wpn.item_type.mask & @weapon_mask != 0
    end
  end
end
