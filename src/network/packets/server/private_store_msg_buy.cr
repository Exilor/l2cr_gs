class Packets::Outgoing::PrivateStoreMsgBuy < GameServerPacket
  @l2id : Int32
  @msg : String?

  def initialize(pc : L2PcInstance)
    @l2id = pc.l2id
    if list = pc.buy_list
      @msg = list.title
    end
  end

  def write_impl
    c 0xbf

    d @l2id
    s @msg
  end
end
