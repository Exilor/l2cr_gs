class Packets::Outgoing::DeleteObject < GameServerPacket
  initializer l2id : Int32

  def initialize(obj : L2Object)
    @l2id = obj.l2id
  end

  private def write_impl
    c 0x08

    d @l2id
    d 0x00 # C2
  end
end
