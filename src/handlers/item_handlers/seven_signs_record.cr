module ItemHandler::SevenSignsRecord
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    playable.send_packet(SSQStatus.new(playable.l2id, 1))
    true
  end
end
