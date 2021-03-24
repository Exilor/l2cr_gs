class Packets::Incoming::RequestJoinDominionWar < GameClientPacket
  @territory_id = 0
  @is_clan = 0
  @is_joining = 0

  private def read_impl
    @territory_id = d
    @is_clan = d
    @is_joining = d
  end

  private def run_impl
    return unless pc = active_char
    clan = pc.clan
    castle_id = @territory_id - 80
    if TerritoryWarManager.registration_over?
      pc.send_packet(SystemMessageId::NOT_TERRITORY_REGISTRATION_PERIOD)
      return
    elsif clan && TerritoryWarManager.get_territory(castle_id).not_nil!.owner_clan == clan
      pc.send_packet(SystemMessageId::THE_TERRITORY_OWNER_CLAN_CANNOT_PARTICIPATE_AS_MERCENARIES)
      return
    end

    if @is_clan == 1
      unless pc.has_clan_privilege?(ClanPrivilege::CS_MANAGE_SIEGE)
        pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
        return
      end
      unless clan
        return
      end

      if @is_joining == 1
        if Time.ms < clan.dissolving_expiry_time
          pc.send_packet(SystemMessageId::CANT_PARTICIPATE_IN_SIEGE_WHILE_DISSOLUTION_IN_PROGRESS)
          return
        elsif TerritoryWarManager.registered?(-1, clan)
          pc.send_packet(SystemMessageId::YOU_ALREADY_REQUESTED_TW_REGISTRATION)
          return
        end

        TerritoryWarManager.register_clan(castle_id, clan)
      else
        TerritoryWarManager.remove_clan(castle_id, clan)
      end
    else
      if pc.level < 40 || pc.class_id.level < 2
        # L2J TODO: punish player
        return
      end

      if @is_joining == 1
        if TerritoryWarManager.registered?(-1, pc.l2id)
          pc.send_packet(SystemMessageId::YOU_ALREADY_REQUESTED_TW_REGISTRATION)
          return
        elsif clan && TerritoryWarManager.registered?(-1, clan)
          pc.send_packet(SystemMessageId::YOU_ALREADY_REQUESTED_TW_REGISTRATION)
          return
        end

        TerritoryWarManager.register_merc(castle_id, pc)
      else
        TerritoryWarManager.remove_merc(castle_id, pc)
      end
    end

    pc.send_packet(ExShowDominionRegistry.new(castle_id, pc))
  end
end
