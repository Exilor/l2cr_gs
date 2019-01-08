class Packets::Incoming::GameGuardReply < GameClientPacket
  no_action_request

  @data = Bytes.empty

  private VALID = {
    0x88, 0x40, 0x1c, 0xa7, 0x83, 0x42, 0xe9, 0x15, 0xde, 0xc3,
    0x68, 0xf6, 0x2d, 0x23, 0xf1, 0x3f, 0xee, 0x68, 0x5b, 0xc5
  }

  def read_impl
    @data = b(4)
    d
    @data += b(4)
  end

  def run_impl
    # TODO: actually check the reply (requires SHA digest).
    debug @data
    client.game_guard_ok = true
  end
end
