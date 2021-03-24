module ItemHandler::Elixir
  extend self
  extend ItemHandler

  def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    ItemHandler::ItemSkillsTemplate.use_item(playable, item, force_use)
  end
end
