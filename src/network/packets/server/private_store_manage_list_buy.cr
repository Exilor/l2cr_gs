class Packets::Outgoing::PrivateStoreManageListBuy < Packets::Outgoing::AbstractItemPacket
  @l2id : Int32
  @adena : Int64
  @item_list : Array(L2ItemInstance)
  @buy_list : IArray(TradeItem)

  def initialize(pc : L2PcInstance)
    @l2id = pc.l2id
    @adena = pc.adena
    @item_list = pc.inventory.get_unique_items(false, true)
    @buy_list = pc.buy_list.items
  end

  def write_impl
    c 0xbd

    d @l2id
    q @adena

    d @item_list.size
    @item_list.each do |item|
      write_item(item)
      q item.template.reference_price * 2
    end

    d @buy_list.size
    @buy_list.each do |item|
      write_item(item)
      q item.price
      q item.item.reference_price * 2
      q item.count
    end
  end
end
