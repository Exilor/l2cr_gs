class Packets::Incoming::RequestDuelSurrender < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    if pc = active_char
      DuelManager.do_surrender(pc)
    end
  end
end
