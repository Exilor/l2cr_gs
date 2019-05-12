class L2MapRegion
  @other_spawns : Array(Location)?
  @chaotic_spawns : Array(Location)?
  @banish_spawns : Array(Location)?
  getter banned_race = EnumMap(Race, String).new
  getter! maps : Array({Int32, Int32})?
  getter! spawns : Array(Location)?

  getter_initializer name: String, town: String, loc_id: Int32, castle: Int32,
    bbs: Int32

  def add_map(x : Int32, y : Int32)
    (@maps ||= [] of {Int32, Int32}) << {x, y}
  end

  def zone_in_region?(x : Int32, y : Int32) : Bool
    !!@maps && maps.any? { |map| map[0] == x && map[1] == y }
  end

  def add_spawn(x : Int32, y : Int32, z : Int32)
    (@spawns ||= [] of Location) << Location.new(x, y, z)
  end

  def add_other_spawn(x : Int32, y : Int32, z : Int32)
    (@other_spawns ||= [] of Location) << Location.new(x, y, z)
  end

  def add_chaotic_spawn(x : Int32, y : Int32, z : Int32)
    (@chaotic_spawns ||= [] of Location) << Location.new(x, y, z)
  end

  def add_banish_spawn(x : Int32, y : Int32, z : Int32)
    (@banish_spawns ||= [] of Location) << Location.new(x, y, z)
  end

  def spawn_loc : Location
    if Config.random_respawn_in_town_enabled
      spawns.sample(random: Rnd)
    else
      spawns[0]
    end
  end

  def other_spawn_loc : Location
    if temp = @other_spawns
      if Config.random_respawn_in_town_enabled
        temp.sample(random: Rnd)
      else
        temp[0]
      end
    else
      spawn_loc
    end
  end

  def chaotic_spawn_loc : Location
    if temp = @chaotic_spawns
      if Config.random_respawn_in_town_enabled
        temp.sample(random: Rnd)
      else
        temp[0]
      end
    else
      spawn_loc
    end
  end

  def banish_spawn_loc : Location
    if temp = @banish_spawns
      if Config.random_respawn_in_town_enabled
        temp.sample(random: Rnd)
      else
        temp[0]
      end
    else
      spawn_loc
    end
  end

  def add_banned_race(race : String, point : String)
    @banned_race[Race.parse(race)] = point
  end
end
