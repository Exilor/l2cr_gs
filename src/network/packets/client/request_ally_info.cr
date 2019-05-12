class Packets::Incoming::RequestAllyInfo < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    return unless pc = active_char

    alliance_id = pc.ally_id

    unless alliance_id > 0
      pc.send_packet(SystemMessageId::NO_CURRENT_ALLIANCES)
      return
    end

    ai = AllianceInfo.new(alliance_id)
    pc.send_packet(ai)

    pc.send_packet(SystemMessageId::ALLIANCE_INFO_HEAD)

    sm = SystemMessage.alliance_name_s1
    sm.add_string(ai.name)
    pc.send_packet(sm)

    sm = SystemMessage.alliance_leader_s2_of_s1
    sm.add_string(ai.leader_c)
    sm.add_string(ai.leader_p)
    pc.send_packet(sm)

    sm = SystemMessage.connection_s1_total_s2
    sm.add_int(ai.online)
    sm.add_int(ai.total)
    pc.send_packet(sm)

    sm = SystemMessage.alliance_clan_total_s1
    sm.add_int(ai.allies.size)
    pc.send_packet(sm)

    sm = SystemMessageId::CLAN_INFO_HEAD

    ai.allies.each do |aci|
      pc.send_packet(sm)

      sm = SystemMessage.clan_info_name_s1
      sm.add_string(aci.clan.name)
      pc.send_packet(sm)

      sm = SystemMessage.clan_info_leader_s1
      sm.add_string(aci.clan.leader_name)
      pc.send_packet(sm)

      sm = SystemMessage.clan_info_level_s1
      sm.add_int(aci.clan.level)
      pc.send_packet(sm)

      sm = SystemMessage.connection_s1_total_s2
      sm.add_int(aci.online)
      sm.add_int(aci.total)
      pc.send_packet(sm)

      sm = SystemMessageId::CLAN_INFO_SEPARATOR
    end

    pc.send_packet(SystemMessageId::CLAN_INFO_FOOT)
  end
end
