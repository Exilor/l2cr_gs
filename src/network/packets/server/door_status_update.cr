class Packets::Outgoing::DoorStatusUpdate < GameServerPacket
  initializer door: L2DoorInstance

  def write_impl
    c 0x4d

    d @door.l2id
    d @door.open? ? 0 : 1
    d @door.damage
    d @door.enemy? ? 1 : 0
    d @door.id
    d @door.current_hp.to_i
    d @door.max_hp
  end
end
