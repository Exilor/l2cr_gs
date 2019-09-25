class Packets::Outgoing::ExNevitAdventEffect < GameServerPacket
  initializer time_left : Int32

  def write_impl
    c 0xfe
    h 0xe0

    d @time_left
  end
end
