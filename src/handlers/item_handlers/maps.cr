module ItemHandler::Maps
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    if playable.player?
      playable.send_packet(ShowMiniMap.new(item.id))
      true
    else
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      false
    end
  end
end
