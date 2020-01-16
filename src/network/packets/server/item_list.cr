require "./abstract_item_packet"

class Packets::Outgoing::ItemList < Packets::Outgoing::AbstractItemPacket
  @items : Array(L2ItemInstance)

  def initialize(@pc : L2PcInstance, @show_window : Bool)
    @items = pc.inventory.items.reject &.quest_item?
  end

  private def write_impl
    c 0x11

    h @show_window ? 1 : 0
    h @items.size

    @items.each { |item| write_item(item) }
    write_inventory_block(@pc.inventory)
  end

  def run_impl
    client.send_packet(ExQuestItemList.new(@pc))
  end
end
