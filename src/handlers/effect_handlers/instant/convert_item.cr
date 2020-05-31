class EffectHandler::ConvertItem < AbstractEffect
  def instant? : Bool
    true
  end

  def on_start(info)
    return unless info.effected.player?
    return unless pc = info.effected.acting_player
    return if pc.looks_dead? || pc.enchanting?
    return unless weapon_item = pc.active_weapon_item
    return unless wpn = (pc.inventory.rhand_slot || pc.inventory.lhand_slot)
    return if wpn.augmented? || weapon_item.change_weapon_id == 0
    new_item_id = weapon_item.change_weapon_id
    return if new_item_id == -1

    enchant_level = wpn.enchant_level
    elementals = wpn.elementals.try &.first?
    unequipped = pc.inventory.unequip_item_in_body_slot_and_record(wpn.template.body_part)
    return if unequipped.empty?
    iu = InventoryUpdate.new
    unequipped.each { |item| iu.add_modified_item(item) }
    pc.send_packet(iu)

    count = 0
    unequipped.each do |item|
      unless item.weapon?
        count &+= 1
        next
      end

      if item.enchant_level > 0
        sm = SystemMessage.equipment_s1_s2_removed
        sm.add_int(item.enchant_level)
        sm.add_item_name(item)
      else
        sm = SystemMessage.s1_disarmed
        sm.add_item_name(item)
      end

      pc.send_packet(sm)
    end

    return if count == unequipped.size

    destroyed = pc.inventory.destroy_item("ChangeWeapon", wpn, pc, nil)
    return unless destroyed
    new_item = pc.inventory.add_item("ChangeWeapon", new_item_id, 1, enchant_level, pc, destroyed)
    return unless new_item

    if elementals && elementals.element != -1 && elementals.value != -1
      new_item.set_element_attr(elementals.element, elementals.value)
    end

    new_item.enchant_level = enchant_level
    pc.inventory.equip_item(new_item)

    if new_item.enchant_level > 0
      sm = SystemMessage.s1_s2_equipped
      sm.add_int(new_item.enchant_level)
      sm.add_item_name(new_item)
    else
      sm = SystemMessage.s1_equipped
      sm.add_item_name(new_item)
    end
    pc.send_packet(sm)

    iu = InventoryUpdate.new
    iu.add_removed_item(destroyed)
    iu.add_item(new_item)
    pc.send_packet(iu)

    pc.broadcast_user_info
  end
end
