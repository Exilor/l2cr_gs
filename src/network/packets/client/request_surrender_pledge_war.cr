class Packets::Incoming::RequestSurrenderPledgeWar < GameClientPacket
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

    sm = SystemMessage.you_have_surrendered_to_the_s1_clan
    sm.add_string(@pledge_name)
    pc.send_packet(sm)

    ClanTable.delete_clan_war(pc_clan.id, enemy_clan.id)
  end
end
