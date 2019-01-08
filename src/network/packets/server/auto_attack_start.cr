class Packets::Outgoing::AutoAttackStart < GameServerPacket
  initializer id: Int32

  def write_impl
    c 0x25
    d @id
  end
end
