class Packets::Incoming::RequestStopPledgeWar < GameClientPacket
  @pledge_name = ""

  private def read_impl
    @pledge_name = s
  end

  private def run_impl
    return unless (pc = active_char) && (pc_clan = pc.clan)

    unless enemy_clan = ClanTable.get_clan_by_name(@pledge_name)
      pc.send_message("No such clan.")
      action_failed
      return
    end

    unless pc_clan.at_war_with?(enemy_clan.id)
      pc.send_message("You aren't at war with this clan.")
      action_failed
      return
    end

    unless pc.has_clan_privilege?(ClanPrivilege::CL_PLEDGE_WAR)
      pc.send_packet(SystemMessageId::YOU_ARE_NOT_AUTHORIZED_TO_DO_THAT)
      return
    end

    pc_clan.members.each do |m|
      unless player = m.player_instance
        next
      end

      if AttackStances.includes?(player)
        pc.send_packet(SystemMessageId::CANT_STOP_CLAN_WAR_WHILE_IN_COMBAT)
        return
      end
    end

    ClanTable.delete_clan_war(pc_clan.id, enemy_clan.id)

    pc_clan.each_online_player &.broadcast_user_info
    enemy_clan.each_online_player &.broadcast_user_info
  end
end
