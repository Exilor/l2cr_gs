class L2MapRegion
  @other_spawns = Slice(Location).empty
  @chaotic_spawns = Slice(Location).empty
  @banish_spawns = Slice(Location).empty

  getter banned_race = EnumMap(Race, String).new
  getter maps = Slice({Int32, Int32}).empty
  getter spawns = Slice(Location).empty

  getter_initializer name : String, town : String, loc_id : Int32,
    castle : Int32, bbs : Int32

  def add_map(x : Int32, y : Int32)
    @maps = @maps.add({x, y})
  end

  def zone_in_region?(x : Int32, y : Int32) : Bool
    @maps.any? { |map| map[0] == x && map[1] == y }
  end

  def add_spawn(x : Int32, y : Int32, z : Int32)
    @spawns = @spawns.add(Location.new(x, y, z))
  end

  def add_other_spawn(x : Int32, y : Int32, z : Int32)
    @other_spawns = @other_spawns.add(Location.new(x, y, z))
  end

  def add_chaotic_spawn(x : Int32, y : Int32, z : Int32)
    @chaotic_spawns = @chaotic_spawns.add(Location.new(x, y, z))
  end

  def add_banish_spawn(x : Int32, y : Int32, z : Int32)
    @banish_spawns = @banish_spawns.add(Location.new(x, y, z))
  end

  def spawn_loc : Location
    if Config.random_respawn_in_town_enabled
      return spawns.sample(random: Rnd)
    end

    spawns[0]
  end

  def other_spawn_loc : Location
    if @other_spawns.empty?
      return spawn_loc
    end

    if Config.random_respawn_in_town_enabled
      @other_spawns.sample(random: Rnd)
    else
      @other_spawns[0]
    end
  end

  def chaotic_spawn_loc : Location
    if @chaotic_spawns.empty?
      return spawn_loc
    end

    if Config.random_respawn_in_town_enabled
      @chaotic_spawns.sample(random: Rnd)
    else
      @chaotic_spawns[0]
    end
  end

  def banish_spawn_loc : Location
    if @banish_spawns.empty?
      return spawn_loc
    end

    if Config.random_respawn_in_town_enabled
      @banish_spawns.sample(random: Rnd)
    else
      @banish_spawns[0]
    end
  end

  def add_banned_race(race : String, point : String)
    @banned_race[Race.parse(race)] = point
  end
end
