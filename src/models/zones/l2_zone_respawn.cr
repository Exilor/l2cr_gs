require "./l2_zone_type"

abstract class L2ZoneRespawn < L2ZoneType
  @spawn_locs : Array(Location)?
  @other_spawn_locs : Array(Location)?
  @chaotic_spawn_locs : Array(Location)?
  @banish_spawn_locs : Array(Location)?

  def parse_loc(x : Int32, y : Int32, z : Int32, type : String?)
    if type.nil? || type.empty?
      add_spawn(x, y, z)
    else
      case type
      when "other"
        add_other_spawn(x, y, z)
      when "chaotic"
        add_chaotic_spawn(x, y, z)
      when "banish"
        add_banish_spawn(x, y, z)
      else
        warn "Unknown location type #{type.inspect}."
      end
    end
  end

  def add_spawn(x : Int32, y : Int32, z : Int32)
    (@spawn_locs ||= [] of Location) << Location.new(x, y, z)
  end

  def add_other_spawn(x : Int32, y : Int32, z : Int32)
    (@other_spawn_locs ||= [] of Location) << Location.new(x, y, z)
  end

  def add_chaotic_spawn(x : Int32, y : Int32, z : Int32)
    (@chaotic_spawn_locs ||= [] of Location) << Location.new(x, y, z)
  end

  def add_banish_spawn(x : Int32, y : Int32, z : Int32)
    (@banish_spawn_locs ||= [] of Location) << Location.new(x, y, z)
  end

  def spawns : Array(Location)?
    @spawn_locs
  end

  def spawn_loc : Location
    if Config.random_respawn_in_town_enabled
      @spawn_locs.not_nil!.sample(random: Rnd)
    else
      @spawn_locs.not_nil!.first
    end
  end

  def other_spawn_loc : Location
    if @other_spawn_locs
      if Config.random_respawn_in_town_enabled
        @other_spawn_locs.not_nil!.sample(random: Rnd)
      else
        @other_spawn_locs.not_nil!.first
      end
    else
      spawn_loc
    end
  end

  def chaotic_spawn_loc : Location
    if @chaotic_spawn_locs
      if Config.random_respawn_in_town_enabled
        @chaotic_spawn_locs.not_nil!.sample(random: Rnd)
      else
        @chaotic_spawn_locs.not_nil!.first
      end
    else
      spawn_loc
    end
  end

  def banish_spawn_loc : Location
    if @banish_spawn_locs
      if Config.random_respawn_in_town_enabled
        @banish_spawn_locs.not_nil!.sample(random: Rnd)
      else
        @banish_spawn_locs.not_nil!.first
      end
    else
      spawn_loc
    end
  end
end
