class Packets::Outgoing::ExPutEnchantTargetItemResult < GameServerPacket
  initializer result : Int32

  private def write_impl
    c 0xfe
    h 0x81

    d @result
  end
end
