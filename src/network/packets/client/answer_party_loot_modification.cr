class Packets::Incoming::AnswerPartyLootModification < GameClientPacket
  @answer = 0

  private def read_impl
    @answer = d
  end

  private def run_impl
    return unless pc = active_char
    return unless party = pc.party?
    party.answer_loot_change_request(pc, @answer == 1)
  end
end
