class Packets::Outgoing::ExMoveToLocationAirship < GameServerPacket
  @id : Int32
  @tx : Int32
  @ty : Int32
  @tz : Int32
  @x : Int32
  @y : Int32
  @z : Int32

  def initialize(char : L2Character)
    @id = char.l2id
    @tx, @ty, @tz = char.x_destination, char.y_destination, char.z_destination
    @x, @y, @z = char.xyz
  end

  def write_impl
    c 0xfe
    h 0x65

    d @id
    d @tx
    d @ty
    d @tz
    d @x
    d @y
    d @z
  end
end
