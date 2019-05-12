class Packets::Incoming::RequestDeleteMacro < GameClientPacket
  @id = 0

  private def read_impl
    @id = d
  end

  private def run_impl
    active_char.try &.delete_macro(@id)
  end
end
