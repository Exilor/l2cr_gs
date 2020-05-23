class Packets::Outgoing::TeleportToLocation < GameServerPacket
  @id : Int32

  def initialize(obj : L2Object, @x : Int32, @y : Int32, @z : Int32, @heading : Int32, *, @fadeout : Bool = false)
    @id = obj.l2id
  end

  private def write_impl
    c 0x22

    d @id
    d @x
    d @y
    d @z
    d @fadeout ? 0 : 1
    d @heading
  end
end
