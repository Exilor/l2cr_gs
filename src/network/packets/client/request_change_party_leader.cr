class Packets::Incoming::RequestChangePartyLeader < GameClientPacket
  @name = ""

  private def read_impl
    @name = s
  end

  private def run_impl
    return unless pc = active_char
    return unless party = pc.party?
    unless party.leader?(pc)
      debug "#{pc.name} is not the party leader."
      return
    end
    party.change_party_leader(@name)
  end
end
