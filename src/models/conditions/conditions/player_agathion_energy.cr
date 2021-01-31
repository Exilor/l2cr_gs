class Condition
  class PlayerAgathionEnergy < self
    initializer energy : Int32

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      return false unless pc = effector.as?(L2PcInstance)

      agathion_info = AgathionRepository.get_by_npc_id(pc.agathion_id)
      if agathion_info.nil? || agathion_info.max_energy <= 0
        return false
      end

      agathion_item = pc.inventory.lbracelet_slot
      if agathion_item.nil? || agathion_info.item_id != agathion_item.id
        return false
      end

      agathion_item.agathion_remaining_energy >= @energy
    end
  end
end
