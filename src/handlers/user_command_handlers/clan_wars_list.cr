module UserCommandHandler::ClanWarsList
  extend self
  extend UserCommandHandler

  private ATTACK_LIST = "SELECT clan_name,clan_id,ally_id,ally_name FROM clan_data,clan_wars WHERE clan1=? AND clan_id=clan2 AND clan2 NOT IN (SELECT clan1 FROM clan_wars WHERE clan2=?)"
  private UNDER_ATTACK_LIST = "SELECT clan_name,clan_id,ally_id,ally_name FROM clan_data,clan_wars WHERE clan2=? AND clan_id=clan1 AND clan1 NOT IN (SELECT clan2 FROM clan_wars WHERE clan1=?)"
  private WAR_LIST = "SELECT clan_name,clan_id,ally_id,ally_name FROM clan_data,clan_wars WHERE clan1=? AND clan_id=clan2 AND clan2 IN (SELECT clan1 FROM clan_wars WHERE clan2=?)"

  def use_user_command(id, pc)
    unless commands.includes?(id)
      return false
    end

    unless clan = pc.clan
      pc.send_packet(SystemMessageId::NOT_JOINED_IN_ANY_CLAN)
      return false
    end

    case id
    when 88
      pc.send_packet(SystemMessageId::CLANS_YOU_DECLARED_WAR_ON)
      sql = ATTACK_LIST
    when 89
      pc.send_packet(SystemMessageId::CLANS_THAT_HAVE_DECLARED_WAR_ON_YOU)
      sql = UNDER_ATTACK_LIST
    else
      pc.send_packet(SystemMessageId::WAR_LIST)
      sql = WAR_LIST
    end

    begin
      GameDB.each(sql, clan.id, clan.id) do |rs|
        clan_name = rs.get_string(:"clan_name")
        ally_id = rs.get_i32(:"ally_id")

        if ally_id > 0
          ally_name = rs.get_string(:"ally_name")

          sm = Packets::Outgoing::SystemMessage.s1_s2_alliance
          sm.add_string(clan_name)
          sm.add_string(ally_name)
        else
          sm = Packets::Outgoing::SystemMessage.s1_no_alli_exists
          sm.add_string(clan_name)
        end

        pc.send_packet(sm)
      end

      pc.send_packet(SystemMessageId::FRIEND_LIST_FOOTER)
    rescue e
      error e
    end

    true
  end

  def commands
    {88, 89, 90}
  end
end
