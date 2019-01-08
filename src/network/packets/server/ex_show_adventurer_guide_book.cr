class Packets::Outgoing::ExShowAdventurerGuideBook < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x38
  end
end
