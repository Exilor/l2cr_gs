module ItemHandler::TeleportBookmark
  extend self
  extend ItemHandler

  def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    pc = playable.acting_player

    if pc.bookmark_slot >= 9
      pc.send_packet(SystemMessageId::YOUR_NUMBER_OF_MY_TELEPORTS_SLOTS_HAS_REACHED_ITS_MAXIMUM_LIMIT)
      return false
    end

    pc.destroy_item("Consume", item.l2id, 1, nil, false)

    pc.bookmark_slot &+= 3
    pc.send_packet(SystemMessageId::THE_NUMBER_OF_MY_TELEPORTS_SLOTS_HAS_BEEN_INCREASED)

    sm = SystemMessage.s1_disappeared
    sm.add_item_name(item.id)
    pc.send_packet(sm)

    true
  end
end
