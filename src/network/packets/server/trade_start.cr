class Packets::Outgoing::TradeStart < Packets::Outgoing::AbstractItemPacket
  @item_list : Array(L2ItemInstance)

  def initialize(@pc : L2PcInstance)
    @item_list = @pc.inventory.get_available_items(true, true, false)
  end

  def write_impl
    return unless trade_list = @pc.active_trade_list
    return unless partner = trade_list.partner

    c 0x14

    d partner.l2id
    h @item_list.size
    @item_list.each { |item| write_item(item) }
  end
end
