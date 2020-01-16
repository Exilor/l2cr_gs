class Packets::Outgoing::ExShowTrace < GameServerPacket
  @locations = [] of Location

  def add_location(x : Int32, y : Int32, z : Int32)
    @locations << Location.new(x, y, z)
  end

  def add_location(loc : Locatable)
    add_location(Location.new(*loc.xyz))
  end

  private def write_impl
    c 0xfe
    h 0x67

    h 0
    d 0
    h @locations.size
    @locations.each { |loc| l loc }
  end
end
