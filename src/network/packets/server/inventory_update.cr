class Packets::Outgoing::InventoryUpdate < Packets::Outgoing::AbstractInventoryUpdate
  def write_impl
    c 0x21
    super
  end

  def self.added(item : L2ItemInstance) : SingleAddedItem
    SingleAddedItem.new(item)
  end

  def self.modified(item : L2ItemInstance) : SingleModifiedItem
    SingleModifiedItem.new(item)
  end

  def self.removed(item : L2ItemInstance) : SingleRemovedItem
    SingleRemovedItem.new(item)
  end

  def self.single(item : L2ItemInstance) : SingleItem
    SingleItem.new(item)
  end

  private class SingleItem < Packets::Outgoing::AbstractItemPacket
    def initialize(item : L2ItemInstance)
      @item = ItemInfo.new(item)
    end

    def item_change
      @item.change
    end

    def write_impl
      c 0x21

      h 1
      h item_change
      write_item(@item)
    end
  end

  private class SingleAddedItem < SingleItem
    def item_change
      1
    end
  end

  private class SingleModifiedItem < SingleItem
    def item_change
      2
    end
  end

  private class SingleRemovedItem < SingleItem
    def item_change
      3
    end
  end
end
