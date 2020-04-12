module VoicedCommandHandler::StatsVCmd
  extend self
  extend VoicedCommandHandler

  private COMMANDS = {"stats"}

  def use_voiced_command(cmd : String, active_char : L2PcInstance, params : String) : Bool
    if cmd != "stats" || params.empty?
      active_char.send_message("Usage: .stats <player name>")
      return false
    end

    unless pc = L2World.get_player(params)
      active_char.send_packet(SystemMessageId::TARGET_IS_NOT_FOUND_IN_THE_GAME)
      return false
    end

    if pc.client.try &.detached?
      sm = SystemMessage.s1_offline
      sm.add_pc_name(pc)
      active_char.send_packet(sm)
      return false
    end

    if !L2Event.participant?(pc) || pc.event_status.nil?
      active_char.send_message("That player is not participating in an event.")
      return false
    end

    status = pc.event_status.not_nil!

    msg = String::Builder.new(300)
    msg << status.kills.size * 50
    msg << "<html><body><center><font color=\"LEVEL\">[ EVENT ENGINE ]</font></center><br><br>Statistics for player <font color=\"LEVEL\">"
    msg << pc.name
    msg << "</font><br>Total kills <font color=\"FF0000\">"
    msg << status.kills.size
    msg << "</font><br><br>Detailed list: <br>"
    status.kills.each do |plr|
      msg << "<font color=\"FF0000\">"
      msg << plr.name
      msg << "</font><br>"
    end
    msg << "</body></html>"

    reply = NpcHtmlMessage.new
    reply.html = msg.to_s
    active_char.send_packet(reply)

    true
  end

  def commands : Indexable(String)
    COMMANDS
  end
end
