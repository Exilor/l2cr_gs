class Condition
  class ChangeWeapon < Condition
    initializer required : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.acting_player?

      if @required
        return false unless weapon_item = pc.active_weapon_item?
        return false if weapon_item.change_weapon_id == 0
        return false if pc.enchanting?
      end

      true
    end
  end
end
