module ItemHandler::Calculator
  extend self
  extend ItemHandler

  def use_item(playable, item, force) : Bool
    if playable.player?
      playable.send_packet(ShowCalculator.new(item.id))
      true
    else
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      false
    end
  end
end
