module UserCommandHandler::ChannelLeave
  extend self
  extend UserCommandHandler

  def use_user_command(id : Int32, pc : L2PcInstance) : Bool
    return false unless id == commands[0]

    unless party = pc.party
      pc.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_LEAVE_CHANNEL)
      return false
    end

    unless party.leader?(pc)
      pc.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_LEAVE_CHANNEL)
      return false
    end

    return false unless cc = party.command_channel

    cc.remove_party(party)
    party.leader.send_packet(SystemMessageId::LEFT_COMMAND_CHANNEL)

    sm = Packets::Outgoing::SystemMessage.c1_party_left_command_channel
    sm.add_pc_name(party.leader)
    cc.broadcast_packet(sm)

    true
  end

  def commands : Enumerable(Int32)
    {96}
  end
end
