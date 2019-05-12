class Packets::Incoming::RequestEnchantItem < GameClientPacket
  @l2id = 0
  @support_id = 0

  private def read_impl
    @l2id  = d
    @support_id = d
  end

  private def run_impl
    return unless pc = active_char
    return if @l2id == 0

    if !pc.online? || client.detached?
      pc.active_enchant_item_id = L2PcInstance::ID_NONE
      return
    end

    if pc.processing_transaction? || pc.in_store_mode?
      send_packet(SystemMessageId::CANNOT_ENCHANT_WHILE_STORE)
      pc.active_enchant_item_id = L2PcInstance::ID_NONE
      return
    end

    inv = pc.inventory

    item = inv.get_item_by_l2id(@l2id)
    scroll = inv.get_item_by_l2id(pc.active_enchant_item_id)
    support = inv.get_item_by_l2id(pc.active_enchant_support_item_id)

    unless item && scroll
      pc.active_enchant_item_id = L2PcInstance::ID_NONE
      return
    end

    unless scroll_template = EnchantItemData.get_enchant_scroll(scroll)
      return
    end

    if support
      if support.l2id != @support_id
        pc.active_enchant_item_id = L2PcInstance::ID_NONE
        return
      end

      support_template = EnchantItemData.get_support_item(support)
    end

    unless scroll_template.valid?(item, support_template)
      send_packet(SystemMessageId::INAPPROPRIATE_ENCHANT_CONDITION)
      pc.active_enchant_item_id = L2PcInstance::ID_NONE
      send_packet(EnchantResult::ERROR)
      return
    end

    timestamp = pc.active_enchant_timestamp
    if timestamp == 0 || Time.ms - timestamp < 2000
      Util.punish(pc, "is enchanting too quickly.")
      pc.active_enchant_item_id = L2PcInstance::ID_NONE
      send_packet(EnchantResult::ERROR)
      return
    end

    unless scroll = inv.destroy_item("Enchant", scroll.l2id, 1, pc, item)
      send_packet(SystemMessageId::NOT_ENOUGH_ITEMS)
      Util.punish(pc, "tried to enchant with a scroll he doesn't have.")
      pc.active_enchant_item_id = L2PcInstance::ID_NONE
      send_packet(EnchantResult::ERROR)
      return
    end

    if support
      support = inv.destroy_item("Enchant", support.l2id, 1, pc, item)
      unless support
        send_packet(SystemMessageId::NOT_ENOUGH_ITEMS)
        Util.punish(pc, "tried to enchant with a support item he doesn't have.")
        pc.active_enchant_item_id = L2PcInstance::ID_NONE
        send_packet(EnchantResult::ERROR)
        return
      end
    end

    iu = InventoryUpdate.new

    item.sync do
      if item.owner_id != pc.l2id || item.enchantable == 0
        send_packet(SystemMessageId::INAPPROPRIATE_ENCHANT_CONDITION)
        pc.active_enchant_item_id = L2PcInstance::ID_NONE
        send_packet(EnchantResult::ERROR)
        return
      end

      case scroll_template.calculate_success(pc, item, support_template)
      when EnchantResultType::ERROR
        send_packet(SystemMessageId::INAPPROPRIATE_ENCHANT_CONDITION)
        pc.active_enchant_item_id = L2PcInstance::ID_NONE
        send_packet(EnchantResult::ERROR)
      when EnchantResultType::SUCCESS
        it = item.template

        if scroll_template.get_chance(pc, item) > 0
          item.enchant_level += 1
          item.update_database
        end
        send_packet(EnchantResult::SUCCESS)
        # optional logging

        min_enchant_announce = item.armor? ? 6 : 7
        max_enchant_announce = item.armor? ? 0 : 15

        if item.enchant_level == min_enchant_announce || item.enchant_level == max_enchant_announce
          sm = SystemMessage.c1_successfuly_enchanted_a_s2_s3
          sm.add_char_name(pc)
          sm.add_int(item.enchant_level)
          sm.add_item_name(item)
          pc.broadcast_packet(sm)

          if sk = CommonSkill::FIREWORK.skill?
            msu = MagicSkillUse.new(pc, pc, sk.id, sk.level, sk.hit_time, sk.reuse_delay)
            pc.broadcast_packet(msu)
          end
        end

        if item.armor? && item.enchant_level == 4 && item.equipped?
          if skill = it.enchant_4_skill
            pc.add_skill(skill, false)
            pc.send_skill_list
          end
        end
      when EnchantResultType::FAILURE
        if scroll_template.safe?
          send_packet(SystemMessageId::SAFE_ENCHANT_FAILED)
          send_packet(EnchantResult::FAILURE)
          # optional logging
        else
          if item.equipped?
            if item.enchant_level > 0
              sm = SystemMessage.equipment_s1_s2_removed
              sm.add_int(item.enchant_level)
              sm.add_item_name(item)
              send_packet(sm)
            else
              sm = SystemMessage.s1_disarmed
              sm.add_item_name(item)
              send_packet(sm)
            end

            inv.unequip_item_in_slot_and_record(item.location_slot).each do |it|
              iu.add_modified_item(it)
            end

            send_packet(iu)
            pc.broadcast_user_info
          end

          if scroll_template.blessed?
            send_packet(SystemMessageId::BLESSED_ENCHANT_FAILED)
            item.enchant_level = 0
            item.update_database
            send_packet(EnchantResult::BLESSED_FAILURE)
            # optional logging
          else
            unless item = inv.destroy_item("Enchant", item, pc, nil)
              Util.punish(pc, "unable to delete item on enchant failure.")
              pc.active_enchant_item_id = L2PcInstance::ID_NONE
              send_packet(EnchantResult::ERROR)
              # optional logging
              return
            end

            L2World.remove_object(item)

            crystal_id = item.template.crystal_item_id
            if crystal_id != 0 && item.template.crystallizable?
              count = item.crystal_count - ((item.template.crystal_count + 1) / 2)
              count = 1 if count < 1
              inv.add_item("Enchant", crystal_id, count.to_i64, pc, item)

              sm = SystemMessage.earned_s2_s1_s
              sm.add_item_name(crystal_id)
              sm.add_long(count)
              send_packet(sm)
              send_packet(EnchantResult.new(1, crystal_id, count))
            else
              send_packet(EnchantResult::NO_CRYSTAL_FAILURE)
            end

            # optional logging
          end
        end
      end

      send_packet(StatusUpdate.current_load(pc))

      if Config.force_inventory_update
        send_packet(ItemList.new(pc, true))
      else
        if scroll.count == 0
          iu.add_removed_item(scroll)
        else
          iu.add_modified_item(scroll)
        end

        if item.count == 0
          iu.add_removed_item(item)
        else
          iu.add_modified_item(item)
        end

        if support
          if support.count == 0
            iu.add_removed_item(support)
          else
            iu.add_modified_item(support)
          end
        end

        send_packet(iu)
      end

      pc.broadcast_user_info
      pc.active_enchant_item_id = L2PcInstance::ID_NONE
    end
  end
end
