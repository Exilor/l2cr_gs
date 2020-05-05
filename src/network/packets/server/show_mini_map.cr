class Packets::Outgoing::ShowMiniMap < GameServerPacket
  initializer map_id : Int32

  private def write_impl
    c 0xa3

    d @map_id
    c SevenSigns.instance.current_period
  end

  DEFAULT = new(1665)
end
