class Packets::Incoming::RequestDuelSurrender < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    if pc = active_char
      DuelManager.do_surrender(pc)
    end
  end
end
