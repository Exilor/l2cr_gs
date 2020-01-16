class Packets::Outgoing::AutoAttackStop < GameServerPacket
  initializer id : Int32

  private def write_impl
    c 0x26
    d @id
  end
end
