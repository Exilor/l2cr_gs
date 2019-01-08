class Packets::Outgoing::StopMove < GameServerPacket
  initializer l2id: Int32, x: Int32, y: Int32, z: Int32, heading: Int32

  def initialize(char : L2Character)
    @l2id = char.l2id
    @x, @y, @z = char.xyz
    @heading = char.heading
  end

  def write_impl
    c 0x47

    d @l2id
    d @x
    d @y
    d @z
    d @heading
  end
end
