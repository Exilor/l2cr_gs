class Packets::Incoming::RequestExMPCCShowPartyMembersInfo < GameClientPacket
  @party_leader_id = 0

  private def read_impl
    @party_leader_id = d
  end

  private def run_impl
    return unless pc = active_char
    unless player = L2World.get_player(@party_leader_id)
      warn { "Party leader with id #{@party_leader_id} not found." }
      return
    end

    if party = player.party
      pc.send_packet(ExMPCCShowPartyMemberInfo.new(party))
    else
      warn { player.name + " doesn't have a party." }
    end
  end
end
