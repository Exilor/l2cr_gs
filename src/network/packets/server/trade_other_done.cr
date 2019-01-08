class Packets::Outgoing::TradeOtherDone < GameServerPacket
  static_packet

  def write_impl
    c 0x82
  end
end
