class Packets::Incoming::AllyLeave < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char

    unless clan = pc.clan?
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_A_CLAN_MEMBER)
      return
    end

    unless pc.clan_leader?
      pc.send_packet(SystemMessageId::ONLY_CLAN_LEADER_WITHDRAW_ALLY)
      return
    end

    if clan.ally_id == 0
      pc.send_packet(SystemMessageId::NO_CURRENT_ALLIANCES)
      return
    end

    if clan.id == clan.ally_id
      pc.send_packet(SystemMessageId::ALLIANCE_LEADER_CANT_WITHDRAW)
      return
    end

    clan.ally_id = 0
    clan.ally_name = nil
    clan.change_ally_crest(0, true)
    pen = Time.ms + (Config.alt_ally_join_days_when_leaved.to_i64 * 86400000)
    clan.set_ally_penalty_expiry_time(pen, L2Clan::PENALTY_TYPE_CLAN_LEAVED)
    clan.update_clan_in_db

    pc.send_packet(SystemMessageId::YOU_HAVE_WITHDRAWN_FROM_ALLIANCE)
  end
end
