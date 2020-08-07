class Packets::Outgoing::ExQuestItemList < Packets::Outgoing::AbstractItemPacket
  @items : Array(L2ItemInstance)

  def initialize(pc : L2PcInstance)
    @pc = pc
    @items = pc.inventory.items.select &.quest_item?
  end

  private def write_impl
    c 0xfe
    h 0xc6

    h @items.size
    @items.each { |item| write_item(item) }
    write_inventory_block(@pc.inventory)
  end
end
