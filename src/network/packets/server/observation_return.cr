class Packets::Outgoing::ObservationReturn < GameServerPacket
  initializer loc : Location

  def write_impl
    c 0xec
    l @loc
  end
end
