require "./item_container"

class PcRefund < ItemContainer
  getter_initializer owner: L2PcInstance

  def owner? : L2PcInstance?
    owner
  end

  def name : String
    "Refund"
  end

  def base_location : ItemLocation
    ItemLocation::REFUND
  end

  def add_item(item : L2ItemInstance)
    super

    begin
      if size > 12
        if removed_item = @items.shift
          ItemTable.destroy_item("ClearRefund", removed_item, owner, nil)
          removed_item.update_database(true)
        end
      end
    rescue e
      error e
    end
  end

  def refresh_weight
    # no-op
  end

  def delete_me
    @items.each do |item|
      begin
        ItemTable.destroy_item("ClearRefund", item, owner, nil)
        item.update_database(true)
      rescue e
        error e
      end
    end
    @items.clear
  end

  def restore
    # no-op
  end
end
