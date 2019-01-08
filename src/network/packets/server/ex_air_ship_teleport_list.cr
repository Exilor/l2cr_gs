class Packets::Outgoing::ExAirShipTeleportList < GameServerPacket
  initializer dock_id: Int32, teleports: Slice(Slice(VehiclePathPoint))?, fuel: Slice(Int32)

  def write_impl
    c 0xfe
    h 0x9a

    if teleports = @teleports
      d teleports.size
      teleports.each_with_index do |path, i|
        d i - 1
        d @fuel[i]
        dst = path[-1]
        l dst
      end
    else
      d 0
    end
  end
end
