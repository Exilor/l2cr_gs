module ItemHandler::SummonItems
  extend self
  extend ItemHandler

  def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    unless TvTEvent.on_item_summon(playable.l2id)
      return false
    end

    pc = playable.acting_player

    unless pc.flood_protectors.item_pet_summon.try_perform_action("summon items")
      return false
    end
    return false if pc.block_checker_arena != -1
    return false if pc.in_observer_mode?
    return false if pc.all_skills_disabled?
    return false if pc.casting_now?

    if pc.sitting?
      pc.send_packet(SystemMessageId::CANT_MOVE_SITTING)
      return false
    end

    if pc.has_summon? || pc.mounted?
      pc.send_packet(SystemMessageId::YOU_ALREADY_HAVE_A_PET)
      return false
    end

    if pc.attacking_now?
      pc.send_packet(SystemMessageId::YOU_CANNOT_SUMMON_IN_COMBAT)
      return false
    end

    pet_data = PetDataTable.get_pet_data_by_item_id(item.id)

    if pet_data.nil? || pet_data.npc_id == -1
      warn { "Bad pet data: #{pet_data.inspect}." }
      return false
    end

    pc.add_script(PetItemHolder.new(item))

    ItemSkillsTemplate.use_item(pc, item, force_use)
  end
end
