require "../../../models/item_info"
require "./abstract_item_packet"

abstract class Packets::Outgoing::AbstractInventoryUpdate < Packets::Outgoing::AbstractItemPacket
  def initialize
    @items = [] of ItemInfo
  end

  def initialize(item : L2ItemInstance)
    @items = [ItemInfo.new(item)]
  end

  def initialize(item : ItemInfo)
    @items = [item]
  end

  def initialize(items : Enumerable(ItemInfo))
    @items = items.to_a
  end

  def add_item(item : L2ItemInstance)
    @items << ItemInfo.new(item)
  end

  def add_new_item(item : L2ItemInstance)
    @items << ItemInfo.new(item, 1)
  end

  def add_modified_item(item : L2ItemInstance)
    @items << ItemInfo.new(item, 2)
  end

  def add_removed_item(item : L2ItemInstance)
    @items << ItemInfo.new(item, 3)
  end

  def add_items(items : Enumerable(L2ItemInstance))
    items.each { |item| @items << ItemInfo.new(item) }
  end

  def write_impl
    h @items.size
    @items.each do |item|
      h item.change
      write_item(item)
    end
  end
end
