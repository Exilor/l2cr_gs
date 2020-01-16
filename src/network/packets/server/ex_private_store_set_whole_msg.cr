class Packets::Outgoing::ExPrivateStoreSetWholeMsg < GameServerPacket
  @l2id : Int32

  def initialize(pc : L2PcInstance, @msg : String)
    @l2id = pc.l2id
  end

  def initialize(pc : L2PcInstance)
    initialize(pc, pc.sell_list.title)
  end

  private def write_impl
    c 0xfe
    h 0x80

    d @l2id
    s @msg
  end
end
