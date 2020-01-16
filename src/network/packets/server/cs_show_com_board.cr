class Packets::Outgoing::CSShowComBoard < GameServerPacket
  initializer html : Bytes

  private def write_impl
    c 0x7b

    c 0x01
    b @html
  end
end
