class Packets::Incoming::RequestDeleteBookMarkSlot < GameClientPacket
  @id = 0

  private def read_impl
    @id = d
  end

  private def run_impl
    active_char.try &.teleport_bookmark_delete(@id)
  end
end
