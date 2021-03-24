class Packets::Outgoing::PrivateStoreListSell < Packets::Outgoing::AbstractItemPacket
  @l2id : Int32
  @adena : Int64
  @items : Concurrent::Array(TradeItem)
  @package_sale : Bool

  def initialize(pc : L2PcInstance, store_pc : L2PcInstance)
    @l2id = store_pc.l2id
    @adena = pc.adena
    @items = store_pc.sell_list.items
    @package_sale = store_pc.sell_list.packaged?
  end

  private def write_impl
    c 0xa1

    d @l2id
    d @package_sale ? 1 : 0
    q @adena
    d @items.size
    @items.each do |item|
      write_item(item)
      q item.price
      q item.item.reference_price &* 2
    end
  end
end
