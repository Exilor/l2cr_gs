class Packets::Outgoing::ObservationMode < GameServerPacket
  initializer loc : Location

  def write_impl
    c 0xeb

    l @loc
    c 0
    c 0xc0
    c 0
  end
end
