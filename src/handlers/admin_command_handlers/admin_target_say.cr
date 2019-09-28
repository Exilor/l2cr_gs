module AdminCommandHandler::AdminTargetSay
  extend self
  extend AdminCommandHandler

  def use_admin_command(command, pc)
    if command.starts_with?("admin_targetsay")
      begin
        obj = pc.target
        if obj.is_a?(L2StaticObjectInstance) || !obj.is_a?(L2Character)
          pc.send_packet(SystemMessageId::INCORRECT_TARGET)
          return false
        end

        message = command.from(16)
        cs = CreatureSay.new(
          obj.l2id,
          obj.player? ? Packets::Incoming::Say2::ALL : Packets::Incoming::Say2::NPC_ALL,
          obj.name,
          message
        )
        obj.broadcast_packet(cs)
      rescue
        pc.send_message("Usage: //targetsay <text>")
        return false
      end
    end

    true
  end

  def commands
    {"admin_targetsay"}
  end
end
