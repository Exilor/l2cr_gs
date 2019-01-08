class Packets::Outgoing::MagicSkillCancel < GameServerPacket
  initializer id: Int32

  def write_impl
    c 0x49
    d @id
  end
end
