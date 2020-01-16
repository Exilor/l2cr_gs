class Packets::Outgoing::ValidateLocation < GameServerPacket
  @id : Int32
  @loc : Location

  def initialize(obj : L2Object)
    @id = obj.l2id
    @loc = obj.location
  end

  private def write_impl
    c 0x79

    d @id
    l @loc
    d @loc.heading
  end
end
