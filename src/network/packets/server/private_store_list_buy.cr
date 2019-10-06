class Packets::Outgoing::PrivateStoreListBuy < Packets::Outgoing::AbstractItemPacket
  @l2id : Int32
  @adena : Int64
  @items : IArray(TradeItem)

  def initialize(pc : L2PcInstance, store_pc : L2PcInstance)
    @l2id = store_pc.l2id
    @adena = pc.adena
    store_pc.sell_list.update_items
    @items = store_pc.buy_list.get_available_items(pc.inventory)
  end

  def write_impl
    c 0xbe

    d @l2id
    q @adena
    d @items.size
    @items.each do |item|
      write_item(item)
      d item.l2id
      q item.price
      q item.item.reference_price * 2
      q item.store_count
    end
  end
end
