class Packets::Outgoing::ExShowQuestInfo < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x20
  end
end
