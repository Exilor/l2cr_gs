class Packets::Outgoing::TargetUnselected < GameServerPacket
  @id : Int32
  @x : Int32
  @y : Int32
  @z : Int32

  def initialize(char : L2Character)
    @id = char.l2id
    @x, @y, @z = char.xyz
  end

  private def write_impl
    c 0x24

    d @id
    d @x
    d @y
    d @z
    d 0x00 # ?
  end
end
