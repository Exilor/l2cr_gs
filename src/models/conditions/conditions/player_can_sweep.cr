class Condition
  class PlayerCanSweep < Condition
    initializer val : Bool

    def test_impl(effector : L2Character, effected : L2Character?, skill : Skill?, item : L2Item?) : Bool
      can_sweep = false

      if pc = effector.acting_player
        skill.try &.get_target_list(pc).each do |target|
          if target.is_a?(L2Attackable) && target.dead?
            if target.spoiled?
              can_sweep = target.check_spoil_owner(pc, true)
              can_sweep &= !target.old_corpse?(pc, Config.corpse_consume_skill_allowed_time_before_decay, true)
              can_sweep &= pc.inventory.check_inventory_slots_and_weight(target.spoil_loot_items, true, true)
            else
              pc.send_packet(SystemMessageId::SWEEPER_FAILED_TARGET_NOT_SPOILED)
            end
          end
        end
      end

      @val == can_sweep
    end
  end
end
