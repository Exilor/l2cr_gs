class Packets::Outgoing::ShowPCCafeCouponShowUI < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x44
  end
end
