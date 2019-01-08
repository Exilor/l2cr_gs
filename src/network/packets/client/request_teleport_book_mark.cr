class Packets::Incoming::RequestTeleportBookMark < GameClientPacket
  @id = 0

  def read_impl
    @id = d
  end

  def run_impl
    active_char.try &.teleport_bookmark_go(@id)
  end
end
