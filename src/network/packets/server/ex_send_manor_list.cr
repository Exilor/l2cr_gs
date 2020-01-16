class Packets::Outgoing::ExSendManorList < GameServerPacket
  static_packet

  private def write_impl
    c 0xfe
    h 0x22

    castles = CastleManager.castles.sort_by &.residence_id
    d castles.size
    castles.each do |castle|
      d castle.residence_id
      s castle.name.downcase
    end
  end
end
