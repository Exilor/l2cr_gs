class Packets::Outgoing::ExCubeGameEnd < GameServerPacket
  initializer red_won : Bool

  def write_impl
    c 0xfe
    h 0x98

    d 0x01

    d @red_won ? 1 : 0
  end
end
