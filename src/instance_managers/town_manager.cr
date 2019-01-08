module TownManager
  extend self

  def get_town_castle(town_id : Int32)
    case town_id
    when 912  then 1
    when 916  then 2
    when 918  then 3
    when 922  then 4
    when 924  then 5
    when 926  then 6
    when 1538 then 7
    when 1537 then 8
    when 1714 then 9
    else 0
    end
  end

  def town_has_castle_in_siege?(town_id : Int32) : Bool
    castle_index = get_town_castle(town_id)

    if castle_index > 0
      idx = CastleManager.get_castle_index(castle_index)
      if castle = CastleManager.castles[idx]?
        return castle.siege.in_progress?
      end
    end

    false
  end

  def town_has_castle_in_siege?(x : Int32, y : Int32) : Bool
    reg = MapRegionManager.get_map_region_loc_id(x, y)
    town_has_castle_in_siege?(reg)
  end

  def get_town(town_id : Int32) : L2TownZone?
    ZoneManager.each(L2TownZone) do |zone|
      if zone.town_id == town_id
        return zone
      end
    end

    nil
  end

  def get_town(x : Int32, y : Int32, z : Int32) : L2TownZone?
    ZoneManager.get_zones(x, y, z).each do |zone|
      if zone.is_a?(L2TownZone)
        return zone
      end
    end

    nil
  end

  def get_town!(x : Int32, y : Int32, z : Int32) : L2TownZone
    unless town = get_town(x, y, z)
      raise "Town with coords #{x}, #{y}, #{z} not found"
    end

    town
  end
end
