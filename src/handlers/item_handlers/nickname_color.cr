module ItemHandler::NicknameColor
  extend self
  extend ItemHandler

  def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
    if playable.player?
      playable.send_packet(ExRequestChangeNicknameColor.new(item.l2id))
      true
    else
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      false
    end
  end
end
