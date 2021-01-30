module HellboundSpawns
  extend self
  extend XMLReader

  private record Level, min : Int32, max : Int32

  private SPAWNS = [] of L2Spawn
  private SPAWN_LEVELS = {} of Int32 => Level

  def load
    SPAWNS.clear
    SPAWN_LEVELS.clear
    parse_datapack_file("scripts/hellbound/hellboundSpawns.xml")
    info { "Loaded #{SPAWNS.size} Hellbound spawns." }
  end

  private def parse_document(doc, file)
    find_element(doc, "list") { |l| each_element(l) { |d| parse_spawn(d) } }
  end

  private def parse_spawn(npc)
    unless npc.name == "npc"
      return
    end

    unless npc_id = parse_int(npc, "id", nil)
      error "Missing NPC id."
      return
    end

    delay = random_interval = 0
    min_level = 1
    max_level = 100
    loc = nil

    each_element(npc) do |n, n_name|
      min_level = 1
      max_level = 100

      case n_name
      when "location"
        heading = parse_int(n, "heading", 0)
        x = parse_int(n, "x")
        y = parse_int(n, "y")
        z = parse_int(n, "z")
        loc = Location.new(x, y, z, heading)
      when "respawn"
        delay = parse_int(n, "delay")
        random_interval = parse_int(n, "randomInterval", 1)
      when "hellboundLevel"
        min_level = parse_int(n, "min", 1)
        max_level = parse_int(n, "max", 100)
      end
    end

    sp = L2Spawn.new(npc_id)
    sp.amount = 1

    if loc
      sp.location = loc
    else
      warn { "Hellbound spawn location is nil for NPC with id #{npc_id}." }
    end
    sp.set_respawn_delay(delay, random_interval)

    SPAWN_LEVELS[npc_id] = Level.new(min_level, max_level)

    SpawnTable.add_new_spawn(sp, false)

    SPAWNS << sp
  end

  def spawns : Array(L2Spawn)
    SPAWNS
  end

  def get_spawn_min_level(npc_id : Int32) : Int32
    if tmp = SPAWN_LEVELS[npc_id]?
      return tmp.min
    end

    1
  end

  def get_spawn_max_level(npc_id : Int32) : Int32
    if tmp = SPAWN_LEVELS[npc_id]?
      return tmp.max
    end

    1
  end
end
