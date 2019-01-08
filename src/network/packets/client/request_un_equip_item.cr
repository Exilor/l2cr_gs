class Packets::Incoming::RequestUnEquipItem < GameClientPacket
  @slot = 0

  def read_impl
    @slot = d
  end

  def run_impl
    return unless pc = active_char
    inv = pc.inventory
    unless item = inv.get_paperdoll_item_by_l2_item_id(@slot)
      debug "Item not found."
      return
    end

    if pc.attacking_now? || pc.casting_now? || pc.casting_simultaneously_now?
      send_packet(SystemMessageId::CANNOT_CHANGE_WEAPON_DURING_AN_ATTACK)
      return
    end

    if @slot == L2Item::SLOT_L_HAND && item.template.is_a?(L2EtcItem)
      # arrows/bolts
      return
    end

    if @slot == L2Item::SLOT_LR_HAND && (pc.cursed_weapon_equipped? || pc.combat_flag_equipped?)
      return
    end

    if pc.stunned? || pc.sleeping? || pc.paralyzed? || pc.looks_dead?
      return
    end

    unless inv.can_manipulate_with_item_id?(item.id)
      send_packet(SystemMessageId::ITEM_CANNOT_BE_TAKEN_OFF)
      return
    end

    if item.weapon? && item.weapon_item!.force_equip? && !pc.override_item_conditions?
      send_packet(SystemMessageId::ITEM_CANNOT_BE_TAKEN_OFF)
      return
    end

    uneq = inv.unequip_item_in_body_slot_and_record(@slot)
    pc.broadcast_user_info

    unless uneq.empty?
      if uneq[0].enchant_level > 0
        sm = SystemMessage.equipment_s1_s2_removed
        sm.add_int(uneq[0].enchant_level)
      else
        sm = SystemMessage.s1_disarmed
      end

      sm.add_item_name(uneq[0])
      send_packet(sm)

      iu = InventoryUpdate.new
      iu.add_items(uneq)
      send_packet(iu)
    end
  end
end
