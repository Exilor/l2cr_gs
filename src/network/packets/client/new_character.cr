class Packets::Incoming::NewCharacter < GameClientPacket
  def read_impl
    # no-op
  end

  def run_impl
    send_packet(NewCharacterSuccess::STATIC_PACKET)
  end
end
