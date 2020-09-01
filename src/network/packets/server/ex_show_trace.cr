class Packets::Outgoing::ExShowTrace < GameServerPacket
  @locations = [] of XYZ

  def add_location(x : Int32, y : Int32, z : Int32)
    @locations << XYZ.new(x, y, z)
  end

  def add_location(loc : Locatable)
    add_location(XYZ.new(loc))
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
