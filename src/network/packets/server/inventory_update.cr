class Packets::Outgoing::InventoryUpdate < Packets::Outgoing::AbstractInventoryUpdate
  def self.added(item : L2ItemInstance)
    new.tap &.add_new_item(item)
  end

  def self.modified(item : L2ItemInstance)
    new.tap &.add_modified_item(item)
  end

  def self.removed(item : L2ItemInstance)
    new.tap &.add_removed_item(item)
  end

  def write_impl
    c 0x21
    super
  end

  class SingleItem < Packets::Outgoing::AbstractItemPacket
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

  class SingleAddedItem < SingleItem
    def item_change
      1
    end
  end

  class SingleModifiedItem < SingleItem
    def item_change
      2
    end
  end

  class SingleRemovedItem < SingleItem
    def item_change
      3
    end
  end
end
