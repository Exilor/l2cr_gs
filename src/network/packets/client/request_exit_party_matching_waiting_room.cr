class Packets::Incoming::RequestExitPartyMatchingWaitingRoom < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    if pc = active_char
      PartyMatchWaitingList.remove_player(pc)
    end
  end
end
