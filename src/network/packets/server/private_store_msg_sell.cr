class Packets::Outgoing::PrivateStoreMsgSell < GameServerPacket
  @l2id : Int32
  @msg : String?

  def initialize(pc : L2PcInstance)
    @l2id = pc.l2id
    if list = pc.sell_list
      @msg = list.title
    end
  end

  private def write_impl
    c 0xa2

    d @l2id
    s @msg
  end
end
