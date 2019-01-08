class Packets::Outgoing::Revive < GameServerPacket
  @id : Int32

  def initialize(obj : L2Object)
    @id = obj.l2id
  end

  def write_impl
    c 0x01
    d @id
  end
end
