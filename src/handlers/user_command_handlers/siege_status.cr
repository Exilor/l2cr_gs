module UserCommandHandler::SiegeStatus
  extend self
  extend UserCommandHandler

  private INSIDE_SIEGE_ZONE = "Castle Siege in Progress"
  private OUTSIDE_SIEGE_ZONE = "No Castle Siege Area"

  def use_user_command(id, pc)
    unless id == commands[0]
      return false
    end

    if !pc.noble? || !pc.clan_leader?
      pc.send_packet(SystemMessageId::ONLY_NOBLESSE_LEADER_CAN_VIEW_SIEGE_STATUS_WINDOW)
      return false
    end

    return false unless clan = pc.clan

    SiegeManager.sieges.each do |siege|
      unless siege.in_progress?
        next
      end

      if !siege.attacker?(clan) && !siege.defender?(clan)
        next
      end

      siege_zone = siege.castle.zone
      str = String.build do |io|
        clan.each_online_player do |m|
          io << "<tr><td width=170>"
          io << m.name
          io << "</td><td width=100>"
          if siege_zone.inside_zone?(m)
            io << INSIDE_SIEGE_ZONE
          else
            io << OUTSIDE_SIEGE_ZONE
          end
        end
      end

      html = Packets::Outgoing::NpcHtmlMessage.new
      html.set_file(pc, "data/html/siege/siege_status.htm")
      html["%kill_count%"] = clan.siege_kills
      html["%death_count%"] = clan.siege_deaths
      html["%member_list%"] = str

      return true
    end
  end

  def commands
    {99}
  end
end
