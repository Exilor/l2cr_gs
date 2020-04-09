class Packets::Incoming::UseItem < GameClientPacket
  private FORMAL_WEAR_ID = 6408

  @l2id = 0
  @ctrl = false

  private def read_impl
    @l2id = d
    @ctrl = d != 0
  end

  private def run_impl
    return unless pc = active_char

    unless flood_protectors.use_item.try_perform_action("use item")
      debug "Flood detected."
      return
    end

    if pc.active_trade_list
      pc.cancel_active_trade
    end

    unless pc.private_store_type.none?
      pc.send_packet(SystemMessageId::CANNOT_TRADE_DISCARD_DROP_ITEM_WHILE_IN_SHOPMODE)
      action_failed
      return
    end

    return unless item = pc.inventory.get_item_by_l2id(@l2id)

    return if custom_item_bypass(pc, item) # custom duh

    if item.template.type_2 == ItemType2::QUEST
      pc.send_packet(SystemMessageId::CANNOT_USE_QUEST_ITEMS)
      return
    end

    if pc.stunned? || pc.paralyzed? || pc.sleeping? || pc.afraid? || pc.looks_dead?
      return
    end

    item_id = item.id

    if pc.dead? || !pc.inventory.can_manipulate_with_item_id?(item_id)
      sm = SystemMessage.s1_cannot_be_used
      sm.add_item_name(item)
      pc.send_packet(sm)
      return
    end

    if !item.equipped? && !item.template.check_condition(pc, pc, true)
      debug "L2Item.check_condition failed."
      return
    end

    if pc.fishing? && (item_id < 6535 || item_id > 6540)
      pc.send_packet(SystemMessageId::CANNOT_DO_WHILE_FISHING_3)
      return
    end

    if !Config.alt_game_karma_player_can_teleport && pc.karma > 0
      item.template.skills.try &.each do |holder|
        if skill = holder.skill?
          if skill.has_effect_type?(EffectType::TELEPORT)
            return
          end
        end
      end
    end

    reuse_delay = item.reuse_delay
    shared_reuse_group = item.shared_reuse_group
    if reuse_delay > 0
      reuse = pc.get_item_remaining_reuse_time(item.l2id)
      if reuse > 0
        reuse_data(pc, item, reuse)
        send_shared_group_update(pc, shared_reuse_group, reuse, reuse_delay, item_id)
        return
      end

      reuse_on_group = pc.get_reuse_delay_on_group(shared_reuse_group)
      if reuse_on_group > 0
        reuse_data(pc, item, reuse_on_group)
        send_shared_group_update(pc, shared_reuse_group, reuse_on_group, reuse_delay, item_id)
        return
      end
    end

    if item.equippable?
      if item_id == FORMAL_WEAR_ID && pc.cursed_weapon_equipped?
        return
      end

      if FortSiegeManager.combat?(item_id)
        return
      end

      if pc.combat_flag_equipped?
        return
      end

      case item.body_part
      when L2Item::SLOT_LR_HAND, L2Item::SLOT_L_HAND, L2Item::SLOT_R_HAND
        if (wpn = pc.active_weapon_item) && wpn.id == 9819
          send_packet(SystemMessageId::CANNOT_EQUIP_ITEM_DUE_TO_BAD_CONDITION)
          return
        end

        if pc.mounted?
          send_packet(SystemMessageId::CANNOT_EQUIP_ITEM_DUE_TO_BAD_CONDITION)
          return
        end

        if pc.disarmed?
          send_packet(SystemMessageId::CANNOT_EQUIP_ITEM_DUE_TO_BAD_CONDITION)
          return
        end

        if pc.cursed_weapon_equipped?
          return
        end

        if !item.equipped? && item.weapon?
          wpn = item.template.as(L2Weapon)

          case pc.race
          when Race::KAMAEL
            case wpn.item_type
            when WeaponType::NONE
              pc.send_packet(SystemMessageId::CANNOT_EQUIP_ITEM_DUE_TO_BAD_CONDITION)
              return
            else
              # [automatically added else]
            end

          else
            case wpn.item_type
            when WeaponType::RAPIER, WeaponType::CROSSBOW, WeaponType::ANCIENTSWORD
              pc.send_packet(SystemMessageId::CANNOT_EQUIP_ITEM_DUE_TO_BAD_CONDITION)
              return
            else
              # [automatically added else]
            end

          end
        end
      when L2Item::SLOT_CHEST, L2Item::SLOT_BACK, L2Item::SLOT_GLOVES, L2Item::SLOT_FEET, L2Item::SLOT_HEAD, L2Item::SLOT_FULL_ARMOR, L2Item::SLOT_LEGS
        if pc.race.kamael? && item.template.item_type == ArmorType::HEAVY
          pc.send_packet(SystemMessageId::CANNOT_EQUIP_ITEM_DUE_TO_BAD_CONDITION)
          return
        end
      when L2Item::SLOT_DECO
        if !item.equipped? && pc.inventory.talisman_slots == 0
          pc.send_packet(SystemMessageId::CANNOT_EQUIP_ITEM_DUE_TO_BAD_CONDITION)
          return
        end
      else
        # [automatically added else]
      end


      if pc.casting_now? || pc.casting_simultaneously_now?
        set_next_action(pc, item)
      elsif pc.attacking_now?
        task = EquipItemTask.new(pc, item)
        ThreadPoolManager.schedule_general(task, pc.attack_end_time - Time.ms)
      else
        pc.use_equippable_item(item, true)
      end
    else
      weapon_item = pc.active_weapon_item
      if weapon_item && weapon_item.item_type == WeaponType::FISHINGROD
        case item_id
        when 6519..6527, 7610..7613, 7807..7809, 8484..8486, 8505..8513
          pc.inventory.lhand_slot = item
          pc.broadcast_user_info
          send_packet(ItemList.new(pc, false))
          return
        else
          # [automatically added else]
        end

      end

      return unless handler = ItemHandler[item.template.as?(L2EtcItem)]

      if handler.use_item(pc, item, @ctrl)
        if reuse_delay > 0
          pc.add_time_stamp_item(item, reuse_delay.to_i64)
          send_shared_group_update(pc, shared_reuse_group, reuse_delay, reuse_delay, item_id)
        end
      end
    end
  end

  private def set_next_action(pc, item)
    next_action = NextAction.new(AI::FINISH_CASTING, AI::CAST) do
      pc.use_equippable_item(item, true)
    end
    pc.ai.next_action = next_action
  end

  private struct EquipItemTask
    initializer pc : L2PcInstance, item : L2ItemInstance

    def call
      @pc.use_equippable_item(@item, false)
    end
  end

  private def reuse_data(pc : L2PcInstance, item : L2ItemInstance, remaining_time : Int)
    hours   =  remaining_time // 3_600_000
    minutes = (remaining_time % 3_000_000) // 60_000
    seconds = (remaining_time // 1000) % 60

    if hours > 0
      sm = SystemMessage.s2_hours_s3_minutes_s4_seconds_remaining_for_reuse_s1
      sm.add_item_name(item)
      sm.add_int(hours)
      sm.add_int(minutes)
    elsif minutes > 0
      sm = SystemMessage.s2_minutes_s3_seconds_remaining_for_reuse_s1
      sm.add_item_name(item)
      sm.add_int(minutes)
    else
      sm = SystemMessage.s2_seconds_remaining_for_reuse_s1
      sm.add_item_name(item)
    end
    sm.add_int(seconds)

    pc.send_packet(sm)
  end

  private def send_shared_group_update(pc : L2PcInstance, group, remaining, reuse, item_id)
    if group > 0
      ex = ExUseSharedGroupItem.new(item_id, group, remaining.to_i32, reuse)
      pc.send_packet(ex)
    end
  end

  private def custom_item_bypass(pc, item) : Bool
    return false unless pc.gm?
    if ls = Packets::Incoming::AbstractRefinePacket::LIFE_STONES[item.id]?
      return true unless wpn = pc.active_weapon_instance

      unequipped = pc.inventory.unequip_item_in_slot_and_record(wpn.location_slot)
      iu = InventoryUpdate.new
      unequipped.each { |i| iu.add_modified_item(i) }
      pc.send_packet(iu)
      pc.broadcast_user_info
      wpn.remove_augmentation

      aug = AugmentationData.generate_random_augmentation(ls.level, ls.grade, wpn.template.body_part, item.id, wpn)
      unless aug
        warn "No augmentation was generated."
        return true
      end
      attempts = 0
      until aug.has_skill?
        aug = AugmentationData.generate_random_augmentation(ls.level, ls.grade, wpn.template.body_part, item.id, wpn)
        unless aug
          warn "No augmentation was generated."
          return true
        end
        attempts += 1
        if attempts > 10000
          pc.send_message "No augmentation with skill could be found after 10.000 attempts."
          return true
        end
      end
      wpn.set_augmentation(aug)

      stat12 = 0x0000FFFF & aug.augmentation_id
      stat34 = aug.augmentation_id >> 16
      pc.send_packet(ExVariationResult.new(stat12, stat34, 1))

      pc.use_equippable_item(wpn, true)

      pc.send_packet(StatusUpdate.current_load(pc))
      return true
    end

    false
  end
end
