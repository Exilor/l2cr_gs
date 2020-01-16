module UserCommandHandler::ChannelInfo
  extend self
  extend UserCommandHandler

  def use_user_command(id, pc)
    unless id == commands[0]
      return false
    end

    return false unless (party = pc.party) && (cc = party.command_channel)

    ex = Packets::Outgoing::ExMultiPartyCommandChannelInfo.new(cc)
    pc.send_packet(ex)

    true
  end

  def commands
    {97}
  end
end
