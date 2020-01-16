class Packets::Outgoing::RequestEnchant < GameServerPacket
  initializer unk : Int32

  private def write_impl
    c 0xfe
    h 0x81

    d @unk
  end
end
