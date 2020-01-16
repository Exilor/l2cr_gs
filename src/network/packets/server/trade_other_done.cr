class Packets::Outgoing::TradeOtherDone < GameServerPacket
  static_packet

  private def write_impl
    c 0x82
  end
end
