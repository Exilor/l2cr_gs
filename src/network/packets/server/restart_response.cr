class Packets::Outgoing::RestartResponse < GameServerPacket
  private initializer response : UInt8

  private def write_impl
    c 0x71
    d @response
  end

  NO  = new(0)
  YES = new(1)
end
