class Packets::Outgoing::ExReplyPostItemList < Packets::Outgoing::AbstractItemPacket
  @item_list : Array(L2ItemInstance)

  def initialize(pc : L2PcInstance)
    @item_list = pc.inventory.get_available_items(true, false, false)
  end

  private def write_impl
    c 0xfe
    h 0xb2

    d @item_list.size
    @item_list.each { |item| write_item(item) }
  end
end
