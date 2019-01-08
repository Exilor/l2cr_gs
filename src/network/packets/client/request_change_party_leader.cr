class Packets::Incoming::RequestChangePartyLeader < GameClientPacket
  @name = ""

  def read_impl
    @name = s
  end

  def run_impl
    return unless pc = active_char
    return unless party = pc.party?
    return unless party.leader?(pc)
    party.change_party_leader(@name)
  end
end
