struct FlyToLocationTask
  initializer char: L2Character, target: L2Character, fly_type: FlyType

  def call
    ftl = Packets::Outgoing::FlyToLocation.new(@char, *@target.xyz, @fly_type)
    @char.broadcast_packet(ftl)
    @char.set_xyz(*@target.xyz)
  end
end
