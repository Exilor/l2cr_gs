module ItemHandler::Maps
  extend self
  extend ItemHandler

  def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
    if playable.player?
      playable.send_packet(ShowMiniMap.new(item.id))
      true
    else
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      false
    end
  end
end
