module UserCommandHandler::ChannelDelete
  extend self
  extend UserCommandHandler

  def use_user_command(id, pc)
    unless id == commands[0]
      return false
    end

    if party = pc.party
      if party.leader?(pc)
        if channel = party.command_channel
          sm = Packets::Outgoing::SystemMessage.command_channel_disbanded
          channel.broadcast_packet(sm)
          channel.disband_channel
          return true
        end
      end
    end

    false
  end

  def commands
    {93}
  end
end
