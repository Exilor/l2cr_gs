require "./warehouse"

class PcWarehouse < Warehouse
  getter_initializer owner: L2PcInstance

  def owner?
    owner
  end

  def name
    "Warehouse"
  end

  def base_location
    ItemLocation::WAREHOUSE
  end

  def validate_capacity(slots)
    @items.size + slots <= @owner.warehouse_limit
  end
end
