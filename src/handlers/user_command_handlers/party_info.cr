module UserCommandHandler::PartyInfo
  extend self
  extend UserCommandHandler

  def use_user_command(id, pc)
    return false unless id == commands[0]

    pc.send_packet(SystemMessageId::PARTY_INFORMATION)

    if party = pc.party
      case party.distribution_type
      when .finders_keepers?
        pc.send_packet(SystemMessageId::LOOTING_FINDERS_KEEPERS)
      when .random?
        pc.send_packet(SystemMessageId::LOOTING_RANDOM)
      when .random_including_spoil?
        pc.send_packet(SystemMessageId::LOOTING_RANDOM_INCLUDE_SPOIL)
      when .by_turn?
        pc.send_packet(SystemMessageId::LOOTING_BY_TURN)
      when .by_turn_including_spoil?
        pc.send_packet(SystemMessageId::LOOTING_BY_TURN_INCLUDE_SPOIL)
      end


      unless party.leader?(pc)
        sm = Packets::Outgoing::SystemMessage.party_leader_c1
        sm.add_pc_name(party.leader)
        pc.send_packet(sm)
      end

      pc.send_message("Members: #{party.size}/9")
    end

    pc.send_packet(SystemMessageId::FRIEND_LIST_FOOTER)

    true
  end

  def commands
    {81}
  end
end
