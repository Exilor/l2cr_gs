module AdminCommandHandler::AdminGmChat
  extend self
  extend AdminCommandHandler

  def use_admin_command(command : String, pc : L2PcInstance) : Bool
    if command.starts_with?("admin_gmchat")
      handle_gm_chat(command, pc)
    elsif command.starts_with?("admin_snoop")
      snoop(command, pc)
    end

    if command.starts_with?("admin_gmchat_menu")
      AdminHtml.show_admin_html(pc, "gm_menu.htm")
    end

    true
  end

  private def snoop(command, pc)
    if command.size > 12
      target = L2World.get_player(command.from(12))
    end

    unless target
      target = pc.target
    end

    unless target
      pc.send_packet(SystemMessageId::SELECT_TARGET)
      return
    end

    unless target.is_a?(L2PcInstance)
      pc.send_packet(SystemMessageId::INCORRECT_TARGET)
      return
    end
    player = target
    player.add_snooper(pc)
    pc.add_snooped(player)
  end

  private def handle_gm_chat(cmd, pc)
    if cmd.starts_with?("admin_gmchat_menu")
      offset = 18
    else
      offset = 13
    end

    text = cmd.from(offset)
    cs = CreatureSay.new(0, Packets::Incoming::Say2::ALLIANCE, pc.name, text)
    AdminData.broadcast_to_gms(cs)
  rescue e
    warn e
  end

  def commands : Enumerable(String)
    {
      "admin_gmchat",
      "admin_snoop",
      "admin_gmchat_menu"
    }
  end
end
