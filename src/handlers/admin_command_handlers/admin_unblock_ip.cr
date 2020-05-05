module AdminCommandHandler::AdminUnblockIp
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command.starts_with?("admin_unblockip")
      begin
        ip = command.from(16)
        if unblock_ip(ip, pc)
          pc.send_message("Unblocked IP #{ip}.")
        end
      rescue
        pc.send_message("Usage: //unblockip <ip>")
      end
    end

    true
  end

  private def unblock_ip(ip, pc)
    # L2J TODO
    # LoginServerClient.instance.unblock_ip(ip)
    warn { "GM #{pc.name} unblocked IP #{ip}." }
    true
  end

  def commands
    {"admin_unblockip"}
  end
end
