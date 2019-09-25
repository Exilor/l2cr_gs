class Condition
  class UsingSlotType < Condition
    initializer mask : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless effector.player?
      return false unless wpn = effector.active_weapon_item?
      wpn.body_part & @mask != 0
    end
  end
end
