class Packets::Incoming::SnoopQuit < GameClientPacket
  @id = 0

  private def read_impl
    @id = d
  end

  private def run_impl
    return unless pc = active_char
    return unless other = L2World.get_player(@id)

    other.remove_snooper(pc)
    pc.remove_snooped(other)
  end
end
