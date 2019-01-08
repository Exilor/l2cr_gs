class Packets::Outgoing::AcquireSkillDone < GameServerPacket
  static_packet

  def write_impl
    c 0x94
  end
end
