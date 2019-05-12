class Packets::Incoming::RequestExitPartyMatchingWaitingRoom < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    if pc = active_char
      PartyMatchWaitingList.remove_player(pc)
    end
  end
end
