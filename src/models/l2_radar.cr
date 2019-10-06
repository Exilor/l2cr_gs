struct L2Radar
  @markers = Concurrent::Array(RadarMarker).new

  initializer pc : L2PcInstance

  def add_marker(x : Int32, y : Int32, z : Int32)
    marker = RadarMarker.new(x, y, z)
    @markers << marker
    @pc.send_packet(Packets::Outgoing::RadarControl.new(2, 2, x, y, z))
    @pc.send_packet(Packets::Outgoing::RadarControl.new(0, 1, x, y, z))
  end

  def remove_marker(x : Int32, y : Int32, z : Int32)
    marker = RadarMarker.new(x, y, z)
    @markers.delete_first(marker)
    rc = Packets::Outgoing::RadarControl.new(1, 1, x, y, z)
    @pc.send_packet(rc)
  end

  def remove_all_markers
    @markers.each do |m|
      rc = Packets::Outgoing::RadarControl.new(2, 2, m.x, m.y, m.z)
      @pc.send_packet(rc)
    end
    @markers.clear
  end

  def load_markers
    rc = Packets::Outgoing::RadarControl.new(2, 2, *@pc.xyz)
    @pc.send_packet(rc)

    @markers.each do |m|
      rc = Packets::Outgoing::RadarControl.new(0, 1, m.x, m.y, m.z)
      @pc.send_packet(rc)
    end
  end

  struct RadarMarker
    @type = 1

    getter_initializer x : Int32, y : Int32, z : Int32
    initializer type : Int32, x : Int32, y : Int32, z : Int32

    def hash
      prime = 31
      result = 1
      result = (prime * result) + @type
      result = (prime * result) + @x
      result = (prime * result) + @y
      (prime * result) + @z
    end
  end
end
