class Packets::Incoming::AllyDismiss < GameClientPacket
  @clan_name = ""

  private def read_impl
    @clan_name = s
  end

  private def run_impl
    return unless pc = active_char

    unless leader_clan = pc.clan
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_A_CLAN_MEMBER)
      return
    end

    if leader_clan.ally_id == 0
      pc.send_packet(SystemMessageId::NO_CURRENT_ALLIANCES)
      return
    end

    if !pc.clan_leader? || leader_clan.id != leader_clan.ally_id
      pc.send_packet(SystemMessageId::FEATURE_ONLY_FOR_ALLIANCE_LEADER)
      return
    end

    unless clan = ClanTable.get_clan_by_name(@clan_name)
      pc.send_packet(SystemMessageId::CLAN_DOESNT_EXISTS)
      return
    end

    if clan.id == leader_clan.id
      pc.send_packet(SystemMessageId::ALLIANCE_LEADER_CANT_WITHDRAW)
      return
    end

    if clan.ally_id != leader_clan.ally_id
      pc.send_packet(SystemMessageId::DIFFERENT_ALLIANCE)
      return
    end

    time = Time.ms
    pen = time + (Config.alt_accept_clan_days_when_dismissed.to_i64 * 86_400_000)
    leader_clan.set_ally_penalty_expiry_time(pen, L2Clan::PENALTY_TYPE_DISMISS_CLAN)
    leader_clan.update_clan_in_db

    clan.ally_id = 0
    clan.ally_name = nil
    clan.change_ally_crest(0, true)

    pen = time + (Config.alt_ally_join_days_when_dismissed.to_i64 * 86_400_000)
    clan.set_ally_penalty_expiry_time(pen, L2Clan::PENALTY_TYPE_CLAN_DISMISSED)
    clan.update_clan_in_db

    pc.send_packet(SystemMessageId::YOU_HAVE_EXPELED_A_CLAN)
  end
end
