class Packets::Incoming::RequestPartyLootModification < GameClientPacket
  @id = 0

  def read_impl
    @id = d
  end

  def run_impl
    return unless pc = active_char

    unless type = PartyDistributionType[@id]?
      warn "No PartyDistributionType found with ID #{@id}."
      return
    end

    return unless party = pc.party?

    if !party.leader?(pc) || type == party.distribution_type
      return
    end

    party.request_loot_change(type)
  end
end
