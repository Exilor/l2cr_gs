class Packets::Outgoing::VehicleCheckLocation < GameServerPacket
  initializer boat : L2Character

  def write_impl
    c 0x6d

    d @boat.l2id
    l @boat
    d @boat.heading
  end
end
