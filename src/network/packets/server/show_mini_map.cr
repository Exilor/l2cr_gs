class Packets::Outgoing::ShowMiniMap < GameServerPacket
  initializer map_id: Int32

  def write_impl
    c 0xa3

    d @map_id
    c SevenSigns.current_period
  end
end
