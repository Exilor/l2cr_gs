struct FlyToLocationTask
  include Runnable

  initializer char: L2Character, target: L2Character, fly_type: FlyType

  def run
    x, y, z = @target.xyz
    ftl = Packets::Outgoing::FlyToLocation.new(@char, x, y, z, @fly_type)
    @char.broadcast_packet(ftl)
    @char.set_xyz(x, y, z)
  end
end
