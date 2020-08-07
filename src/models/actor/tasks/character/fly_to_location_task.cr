struct FlyToLocationTask
  initializer char : L2Character, target : L2Character, fly_type : FlyType

  def call
    xyz = @target.xyz
    ftl = Packets::Outgoing::FlyToLocation.new(@char, *xyz, @fly_type)
    @char.broadcast_packet(ftl)
    @char.set_xyz(*xyz)
  end
end
