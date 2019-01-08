module ItemHandler::ManaPotion
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    if Config.enable_mana_potions_support
      ItemHandler::ItemSkillsTemplate.use_item(playable, item, force)
    else
      playable.send_packet(SystemMessageId::NOTHING_HAPPENED)
      false
    end
  end
end
