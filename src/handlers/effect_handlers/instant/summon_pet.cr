require "../../../models/holders/pet_item_holder"

class EffectHandler::SummonPet < AbstractEffect
  def on_start(info)
    return unless info.effector
    return unless info.effected
    return unless info.effector.player?
    return unless info.effected.player?
    return if info.effected.looks_dead?

    pc = info.effector.acting_player

    if pc.has_summon? || pc.mounted?
      pc.send_packet(SystemMessageId::YOU_ALREADY_HAVE_A_PET)
      return
    end

    unless holder = pc.remove_script(PetItemHolder)
      warn "#{pc} attempted to summon a pet without a PetItemHolder"
      return
    end

    item = holder.item

    if pc.inventory.get_item_by_l2id(item.l2id) != item
      warn "#{pc} tried to summon a pet he doesn't own."
      return
    end

    pet_data = PetDataTable.get_pet_data_by_item_id(item.id)

    return if !pet_data || pet_data.npc_id == -1

    template = NpcData[pet_data.npc_id]
    unless pet = L2PetInstance.spawn_pet(template, pc, item)
      raise "L2PetInstance.spawn_pet failed"
    end

    pet.show_summon_animation = true

    unless pet.respawned?
      pet.heal!
      pet.stat.exp = pet.exp_for_this_level
      pet.current_feed = pet.max_fed
    end

    pet.set_running

    unless pet.respawned?
      pet.store_me
    end

    item.enchant_level = pet.level
    pc.pet = pet
    pet.spawn_me(pc.x + 50, pc.y + 100, pc.z)
    pet.start_feed
    pet.follow_status = true
    pet.owner.send_packet(PetItemList.new(pet.inventory.items))
    pet.broadcast_status_update
  end

  def instant?
    true
  end
end
