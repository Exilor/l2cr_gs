class Packets::Incoming::RequestJoinSiege < GameClientPacket
  @castle_id = 0
  @attacker = 0
  @joining = 0

  def read_impl
    @castle_id = d
    @attacker = d
    @joining = d
  end

  def run_impl
    return unless pc = active_char

    unless pc.has_clan_privilege?(ClanPrivilege::CS_MANAGE_SIEGE)
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return
    end

    unless clan = pc.clan?
      return
    end

    if castle = CastleManager.get_castle_by_id(@castle_id)
      if @joining == 1
        if Time.ms < clan.dissolving_expiry_time
          pc.send_packet(SystemMessageId::CANT_PARTICIPATE_IN_SIEGE_WHILE_DISSOLUTION_IN_PROGRESS)
          return
        end

        if @attacker == 1
          castle.siege.register_attacker(pc)
        else
          castle.siege.register_defender(pc)
        end
      else
        castle.siege.remove_siege_clan(pc)
      end

      castle.siege.list_register_clan(pc)
    end

    if hall = CHSiegeManager.get_siegable_hall(@castle_id)
      if @joining == 1
        if Time.ms < clan.dissolving_expiry_time
          pc.send_packet(SystemMessageId::CANT_PARTICIPATE_IN_SIEGE_WHILE_DISSOLUTION_IN_PROGRESS)
          return
        end

        CHSiegeManager.register_clan(clan, hall, pc)
      else
        CHSiegeManager.unregister_clan(clan, hall)
      end

      pc.send_packet(SiegeInfo.new(hall))
    end
  end
end
