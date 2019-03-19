module HellboundSpawns
  extend self
  extend XMLReader

  private SPAWNS = [] of L2Spawn
  private SPAWN_LEVELS = {} of Int32 => {Int32, Int32}

  def load
    SPAWNS.clear
    SPAWN_LEVELS.clear
    parse_datapack_file("scripts/hellbound/hellboundSpawns.xml")
    info "Loaded #{SPAWNS.size} Hellbound spawns."
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |list|
      list.each_element do |d|
        parse_spawn(d)
      end
    end
  end

  private def parse_spawn(npc)
    unless npc.name == "npc"
      return
    end

    unless tmp = npc["id"]?
      error "Missing NPC id."
      return
    end

    npc_id = tmp.to_i
    delay = random_interval = 0
    min_level = 1
    max_level = 100
    loc = nil

    npc.each_element do |n|
      min_level = 1
      max_level = 100

      case n.name
      when "location"
        heading = n["heading"]?.try &.to_i || 0
        loc = Location.new(n["x"].to_i, n["y"].to_i, n["z"].to_i, heading)
      when "respawn"
        delay = n["delay"].to_i
        if tmp = n["randomInterval"]?
          random_interval = tmp.to_i
        else
          random_interval = 1
        end
      when "hellboundLevel"
        min_level = n["min"]?.try &.to_i || 1
        max_level = n["max"]?.try &.to_i || 100
      end
    end

    sp = L2Spawn.new(npc_id)
    sp.amount = 1

    if loc
      sp.location = loc
    else
      warn "Hellbound spawn location is nil for NPC with id #{npc_id}."
    end
    sp.set_respawn_delay(delay, random_interval)

    SPAWN_LEVELS[npc_id] = {min_level, max_level}

    SpawnTable.add_new_spawn(sp, false)

    SPAWNS << sp
  end

  def spawns : Array(L2Spawn)
    SPAWNS
  end

  def get_spawn_min_level(npc_id : Int32) : Int32
    if tmp = SPAWN_LEVELS[npc_id]?
      return tmp[0]
    end

    1
  end

  def get_spawn_max_level(npc_id : Int32) : Int32
    if tmp = SPAWN_LEVELS[npc_id]?
      return tmp[1]
    end

    1
  end
end
