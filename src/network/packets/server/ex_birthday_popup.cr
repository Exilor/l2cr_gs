class Packets::Outgoing::ExBirthdayPopup < GameServerPacket
  static_packet

  def write_impl
    c 0xfe
    h 0x8f
  end
end
