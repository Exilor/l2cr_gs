class Packets::Outgoing::PartySmallWindowDeleteAll < GameServerPacket
  static_packet

  def write_impl
    c 0x50
  end
end
