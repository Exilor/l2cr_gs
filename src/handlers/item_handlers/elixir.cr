module ItemHandler::Elixir
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    ItemHandler::ItemSkillsTemplate.use_item(playable, item, force)
  end
end
