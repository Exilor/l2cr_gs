require "./warehouse"

class PcWarehouse < Warehouse
  getter_initializer owner: L2PcInstance

  def owner? : L2PcInstance?
    owner
  end

  def name : String
    "Warehouse"
  end

  def base_location : ItemLocation
    ItemLocation::WAREHOUSE
  end

  def validate_capacity(slots : Int) : Bool
    @items.size + slots <= @owner.warehouse_limit
  end
end
