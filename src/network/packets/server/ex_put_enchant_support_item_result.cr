class Packets::Outgoing::ExPutEnchantSupportItemResult < GameServerPacket
  initializer result : Int32

  def write_impl
    c 0xfe
    h 0x82

    d @result
  end
end
