class Packets::Outgoing::MoveToLocation < GameServerPacket
  @id : Int32
  @x : Int32
  @y : Int32
  @z : Int32
  @xd : Int32
  @yd : Int32
  @zd : Int32

  def initialize(char : L2Character)
    @id = char.l2id
    @x, @y, @z  = char.xyz
    @xd = char.x_destination
    @yd = char.y_destination
    @zd = char.z_destination
  end

  private def write_impl
    c 0x2f

    d @id
    d @xd
    d @yd
    d @zd
    d @x
    d @y
    d @z
  end
end
