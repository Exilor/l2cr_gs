class Packets::Incoming::RequestGiveItemToPet < GameClientPacket
  @l2id = 0
  @amount = 0i64

  private def read_impl
    @l2id = d
    @amount = q
  end

  private def run_impl
    return unless pc = active_char
    return unless @amount > 0
    return unless pet = pc.summon.as?(L2PetInstance)

    unless flood_protectors.transaction.try_perform_action("giveitemtopet")
      pc.send_message("You are giving items to pet too fast.")
      return
    end
    return unless pc.active_enchant_item_id == L2PcInstance::ID_NONE
    return if !Config.alt_game_karma_player_can_trade && pc.karma > 0
    unless pc.private_store_type.none?
      pc.send_message("You cannot exchange items while trading.")
      return
    end
    return unless item = pc.inventory.get_item_by_l2id(@l2id)
    if @amount > item.count
      # handle illega player action
      return
    end
    return if item.augmented?
    if item.hero_item? || !item.droppable? || !item.destroyable? || !item.tradeable?
      pc.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return
    end

    if pet.dead?
      pc.send_packet(SystemMessageId::CANNOT_GIVE_ITEMS_TO_DEAD_PET)
      return
    end

    unless pet.inventory.validate_capacity(item)
      pc.send_packet(SystemMessageId::YOUR_PET_CANNOT_CARRY_ANY_MORE_ITEMS)
      return
    end

    unless pet.inventory.validate_weight(item, @amount)
      pc.send_packet(SystemMessageId::UNABLE_TO_PLACE_ITEM_YOUR_PET_IS_TOO_ENCUMBERED)
      return
    end

    unless pc.transfer_item("Transfer", @l2id, @amount, pet.inventory, pet)
      warn "Invalid item transfer request from #{pc} to #{pet}."
    end
  end
end
