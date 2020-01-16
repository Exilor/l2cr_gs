class Packets::Outgoing::ExVariationResult < GameServerPacket
  initializer stat12 : Int32, stat34 : Int32, unk3 : Int32

  private def write_impl
    c 0xfe
    h 0x56

    d @stat12
    d @stat34
    d @unk3
  end

  STATIC_PACKET = new(0, 0, 0)
end
