module ItemHandler::ManaPotion
  extend self
  extend ItemHandler

  def use_item(playable : L2Playable, item : L2ItemInstance, force_use : Bool) : Bool
    if Config.enable_mana_potions_support
      ItemHandler::ItemSkillsTemplate.use_item(playable, item, force_use)
    else
      playable.send_packet(SystemMessageId::NOTHING_HAPPENED)
      false
    end
  end
end
