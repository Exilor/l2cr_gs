class Packets::Outgoing::AcquireSkillDone < GameServerPacket
  static_packet

  private def write_impl
    c 0x94
  end
end
