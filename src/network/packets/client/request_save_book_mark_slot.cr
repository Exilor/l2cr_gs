class Packets::Incoming::RequestSaveBookMarkSlot < GameClientPacket
  @name = ""
  @icon = 0
  @tag = ""

  def read_impl
    @name = s
    @icon = d
    @tag = s
  end

  def run_impl
    return unless pc = active_char
    pc.teleport_bookmark_add(*pc.xyz, @icon, @tag, @name)
  end
end
