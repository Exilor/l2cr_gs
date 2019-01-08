class Packets::Outgoing::PrivateStoreManageListSell < Packets::Outgoing::AbstractItemPacket
  @l2id : Int32
  @adena : Int64
  @item_list : Array(TradeItem)
  @sell_list : Array(TradeItem)

  def initialize(pc : L2PcInstance, @package_sale : Bool)
    @l2id = pc.l2id
    @adena = pc.adena
    pc.sell_list.update_items
    @item_list = pc.inventory.get_available_items(pc.sell_list)
    @sell_list = pc.sell_list.items
  end

  def write_impl
    c 0xa0

    d @l2id
    d @package_sale ? 1 : 0
    q @adena

    d @item_list.size
    @item_list.each do |item|
      write_item(item)
      q item.item.reference_price * 2
    end

    d @sell_list.size
    @sell_list.each do |item|
      write_item(item)
      q item.price
      q item.item.reference_price * 2
    end
  end
end
