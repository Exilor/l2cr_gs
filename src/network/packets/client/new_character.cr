class Packets::Incoming::NewCharacter < GameClientPacket
  private def read_impl
    # no-op
  end

  private def run_impl
    send_packet(NewCharacterSuccess::STATIC_PACKET)
  end
end
