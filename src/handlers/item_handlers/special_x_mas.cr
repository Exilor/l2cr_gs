module ItemHandler::SpecialXMas
  extend self
  extend ItemHandler

  def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    playable.broadcast_packet(ShowXMasSeal.new(item.id))

    true
  end
end
