class Packets::Outgoing::ExAttributeEnchantResult < GameServerPacket
  initializer result : Int32

  private def write_impl
    c 0xfe
    h 0x61

    d @result
  end
end
