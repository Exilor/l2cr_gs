require "./item_container"

class PcFreight < ItemContainer
  @owner : L2PcInstance?
  getter owner_id : Int32

  def initialize(@owner_id : Int32)
  end

  def initialize(@owner : L2PcInstance)
    @owner_id = owner.l2id
    restore
  end

  def owner? : L2PcInstance?
    @owner
  end

  def base_location : ItemLocation
    ItemLocation::FREIGHT
  end

  def name : String
    "Freight"
  end

  def validate_capacity(slots : Int) : Bool
    cur_slots = Config.alt_freight_slots

    if @owner
      cur_slots += owner.calc_stat(Stats::FREIGHT_LIM, 0).to_i
    end

    size + slots <= cur_slots
  end

  def refresh_weight
    # no-op
  end
end
