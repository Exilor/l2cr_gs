class Packets::Outgoing::ShowTownMap < GameServerPacket
  initializer texture : String, x : Int32, y : Int32

  def write_impl
    c 0xea

    s @texture
    d @x
    d @y
  end
end
