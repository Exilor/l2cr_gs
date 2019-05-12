class Packets::Incoming::RequestPetUseItem < GameClientPacket
  @l2id = 0

  private def read_impl
    @l2id = d
    # L2J hasn't completed this
  end

  private def run_impl
    return unless pc = active_char
    return unless pet = pc.summon.as?(L2PetInstance)

    unless flood_protectors.use_item.try_perform_action("pet use item")
      debug "Flood detected."
      return
    end

    return unless item = pet.inventory.get_item_by_l2id(@l2id)

    unless item.template.for_npc?
      pc.send_packet(SystemMessageId::PET_CANNOT_USE_ITEM)
      return
    end

    if pc.looks_dead? || pet.dead?
      sm = SystemMessage.s1_cannot_be_used
      sm.add_item_name(item)
      pc.send_packet(sm)
      return
    end

    reuse_delay = item.reuse_delay

    if reuse_delay > 0
      reuse = pet.get_item_remaining_reuse_time(item.l2id)
      if reuse > 0
        debug "#{item} is on cooldown."
        return
      end
    end

    if !item.equipped? && !item.template.check_condition(pet, pet, true)
      debug "#{!item.equipped?} && #{!item.template.check_condition(pet, pet, true)}"
      return
    end

    if item.equippable?
      unless item.template.condition_attached?
        debug "item has no condition attached"
        send_packet(SystemMessageId::PET_CANNOT_USE_ITEM)
        return
      end

      if item.equipped?
        pet.inventory.unequip_item_in_slot(item.location_slot)
      else
        pet.inventory.equip_item(item)
      end

      pc.send_packet(PetItemList.new(pet.inventory.items))
      pet.update_and_broadcast_status(1)
    else
      if handler = ItemHandler[item.etc_item]
        if handler.use_item(pet, item, false)
          reuse_delay = item.reuse_delay
          if reuse_delay > 0
            pc.add_time_stamp_item(item, reuse_delay.to_i64)
          end
          pet.update_and_broadcast_status(1)
        end
      else
        send_packet(SystemMessageId::PET_CANNOT_USE_ITEM)
        warn "No item handler for #{item}."
      end
    end
  end
end
