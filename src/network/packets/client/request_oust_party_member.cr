class Packets::Incoming::RequestOustPartyMember < GameClientPacket
  @name = ""

  private def read_impl
    @name = s
  end

  private def run_impl
    return unless pc = active_char
    return unless party = pc.party?
    return unless party.leader?(pc)
    if party.in_dimensional_rift? && !party.dimensional_rift.revived_at_waiting_room.includes?(pc)
      pc.send_message("You can't dismiss party members when you are in Dimensional Rift.")
    else
      party.remove_party_member(@name, L2Party::MessageType::Expelled)
    end
  end
end
