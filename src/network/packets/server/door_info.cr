class Packets::Outgoing::DoorInfo < GameServerPacket
  initializer door: L2DoorInstance

  def write_impl
    c 0x4c

    d @door.l2id
    d @door.id
  end
end
