class Packets::Outgoing::RestartResponse < GameServerPacket
  private initializer response: Bool

  def write_impl
    c 0x71
    d @response ? 1 : 0
  end

  NO  = new(false)
  YES = new(true)
end
