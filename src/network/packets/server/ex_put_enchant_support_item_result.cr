class Packets::Outgoing::ExPutEnchantSupportItemResult < GameServerPacket
  initializer result : Int32

  private def write_impl
    c 0xfe
    h 0x82

    d @result
  end

  ZERO = new(0)
end
