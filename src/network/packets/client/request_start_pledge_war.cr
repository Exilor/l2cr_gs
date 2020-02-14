class Packets::Incoming::RequestStartPledgeWar < GameClientPacket
  @pledge_name = ""

  private def read_impl
    @pledge_name = s
  end

  private def run_impl
    return unless (pc = active_char) && (pc_clan = pc.clan)

    if pc_clan.level < 3 || pc_clan.size < Config.alt_clan_members_for_war
      pc.send_packet(SystemMessageId::CLAN_WAR_DECLARED_IF_CLAN_LVL3_OR_15_MEMBER)
      action_failed
      return
    elsif !pc.has_clan_privilege?(ClanPrivilege::CL_PLEDGE_WAR)
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      action_failed
      return
    end

    unless enemy_clan = ClanTable.get_clan_by_name(@pledge_name)
      pc.send_packet(SystemMessageId::CLAN_WAR_CANNOT_DECLARED_CLAN_NOT_EXIST)
      action_failed
      return
    end

    if pc_clan.ally_id == enemy_clan.ally_id && pc_clan.ally_id != 0
      pc.send_packet(SystemMessageId::CLAN_WAR_AGAINST_A_ALLIED_CLAN_NOT_WORK)
      action_failed
      return
    elsif enemy_clan.level < 3 || enemy_clan.size < Config.alt_clan_members_for_war
      pc.send_packet(SystemMessageId::CLAN_WAR_DECLARED_IF_CLAN_LVL3_OR_15_MEMBER)
      action_failed
      return
    elsif pc_clan.at_war_with?(enemy_clan.id)
      sm = SystemMessage.already_at_war_with_s1_wait_5_days
      sm.add_string(enemy_clan.name)
      pc.send_packet(sm)
      action_failed
      return
    end

    ClanTable.store_clan_war(pc_clan.id, enemy_clan.id)

    pc_clan.each_online_player &.broadcast_user_info
    enemy_clan.each_online_player &.broadcast_user_info
  end
end
