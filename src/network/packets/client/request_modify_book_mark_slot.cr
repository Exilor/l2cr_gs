class Packets::Incoming::RequestModifyBookMarkSlot < GameClientPacket
  @id = 0
  @name = ""
  @icon = 0
  @tag = ""

  private def read_impl
    @id = d
    @name = s
    @icon = d
    @tag = s
  end

  private def run_impl
    active_char.try &.teleport_bookmark_modify(@id, @icon, @tag, @name)
  end
end
