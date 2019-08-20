module ItemHandler::Disguise
  extend self
  extend ItemHandler

  def use_item(playable, item, force)
    unless playable.player?
      playable.send_packet(SystemMessageId::ITEM_NOT_FOR_PETS)
      return false
    end

    pc = playable.acting_player

    reg_id = TerritoryWarManager.get_registered_territory_id(pc)
    if reg_id > 0 && reg_id == item.id - 13596
      clan = pc.clan?
      if clan && clan.castle_id > 0
        pc.send_packet(SystemMessageId::TERRITORY_OWNING_CLAN_CANNOT_USE_DISGUISE_SCROLL)
        return false
      end

      TerritoryWarManager.add_disguised_player(pc.l2id)
      pc.broadcast_user_info
      pc.destroy_item("Consume", item.l2id, 1, nil, false)
      true
    elsif reg_id > 0
      pc.send_packet(SystemMessageId::THE_DISGUISE_SCROLL_MEANT_FOR_DIFFERENT_TERRITORY)
      false
    else
      pc.send_packet(SystemMessageId::TERRITORY_WAR_SCROLL_CAN_NOT_USED_NOW)
      false
    end
  end
end
