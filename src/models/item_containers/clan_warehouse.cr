require "./warehouse"

class ClanWarehouse < Warehouse
  initializer clan: L2Clan

  def name
    "ClanWarehouse"
  end

  def owner?
    @clan.leader.player_instance?
  end

  def owner_id
    @clan.id
  end

  def base_location
    ItemLocation::CLANWH
  end

  def get_location_id(arg)
    "0"
  end

  def location_id=(arg)
    # no-op
  end

  def validate_capacity(slots : Int) : Bool
    @items.size + slots <= Config.warehouse_slots_clan
  end

  # TODO: override methods and notify to scripts
end
