class Packets::Incoming::RequestDeleteMacro < GameClientPacket
  @id = 0

  def read_impl
    @id = d
  end

  def run_impl
    active_char.try &.delete_macro(@id)
  end
end
