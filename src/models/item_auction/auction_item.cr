struct AuctionItem
  getter auction_item_id, auction_length, auction_init_bid, item_id, item_count

  initializer auction_item_id : Int32, auction_length : Int32,
    auction_init_bid : Int64, item_id : Int32, item_count : Int64,
    item_extra : StatsSet

  def check_item_exists : Bool
    !!ItemTable[@item_id]?
  end

  def create_new_item_instance : L2ItemInstance
    item = ItemTable.create_item("ItemAuction", @item_id, @item_count, nil, nil)

    item.enchant_level = item.default_enchant_level

    augmentation_id = @item_extra.get_i32("augmentation_id", 0)
    if augmentation_id > 0
      item.set_augmentation(L2Augmentation.new(augmentation_id))
    end

    item
  end
end
