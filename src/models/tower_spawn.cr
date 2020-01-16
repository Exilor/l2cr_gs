class TowerSpawn
  property upgrade_level : Int32 = 0
  getter_initializer id : Int32, location : Location,
    zone_list : Array(Int32)? = nil
end
