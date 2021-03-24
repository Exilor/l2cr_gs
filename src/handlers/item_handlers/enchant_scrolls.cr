module ItemHandler::EnchantScrolls
  extend self
  extend ItemHandler

  def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    pc = playable.acting_player

    return false if pc.casting_now?

    if pc.enchanting?
      pc.send_packet(SystemMessageId::ENCHANTMENT_ALREADY_IN_PROGRESS)
      return false
    end

    pc.active_enchant_item_id = item.l2id
    pc.send_packet(ChooseInventoryItem.new(item.id))

    true
  end
end
