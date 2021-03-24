module UserCommandHandler::ChannelInfo
  extend self
  extend UserCommandHandler

  def use_user_command(id : Int32, pc : L2PcInstance) : Bool
    return false unless id == commands[0]
    return false unless (party = pc.party) && (cc = party.command_channel)

    ex = Packets::Outgoing::ExMultiPartyCommandChannelInfo.new(cc)
    pc.send_packet(ex)

    true
  end

  def commands : Enumerable(Int32)
    {97}
  end
end
