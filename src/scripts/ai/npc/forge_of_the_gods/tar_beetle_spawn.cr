require "../../../../models/l2_territory"

class TarBeetleSpawn
  include XMLReader

  private ZONES = [] of SpawnZone
  private REFRESH_SPAWN_TASK = -> { ZONES.each &.refresh_spawn }
  private REFRESH_SHOTS_TASK = -> { ZONES.each &.refresh_shots }

  @spawn_task : TaskScheduler::PeriodicTask?
  @shot_task : TaskScheduler::PeriodicTask?

  def initialize
    load
  end

  def load
    parse_datapack_file("spawnZones/tar_beetle.xml")
    info { "Loaded #{ZONES.size} spawn zones." }
    unless ZONES.empty?
      @spawn_task = ThreadPoolManager.schedule_general_at_fixed_rate(REFRESH_SPAWN_TASK, 1000, 60_000)
      @shot_task = ThreadPoolManager.schedule_general_at_fixed_rate(REFRESH_SHOTS_TASK, 300_000, 300_000)
    end
  end

  private def parse_document(doc : XML::Node, file : File)
    find_element(doc, "list") do |d|
      find_element(d, "spawnZone") do |r|
        npc_count = parse_int(r, "maxNpcCount")
        sp = SpawnZone.new(npc_count, ZONES.size)
        find_element(r, "zone") do |b|
          min_z = parse_int(b, "minZ")
          max_z = parse_int(b, "maxZ")
          zone = Zone.new
          each_element(b) do |c, c_name|
            if c_name == "point"
              x = parse_int(c, "x")
              y = parse_int(c, "y")
              zone.add(x, y, min_z, max_z, 0)
            elsif c_name == "bannedZone"
              banned_zone = Zone.new
              b_min_z = parse_int(c, "minZ")
              b_max_z = parse_int(c, "maxZ")
              find_element(c, "point") do |f|
                x = parse_int(f, "x")
                y = parse_int(f, "y")
                banned_zone.add(x, y, b_min_z, b_max_z, 0)
              end
              zone.add_banned_zone(banned_zone)
            end
            sp.add_zone(zone)
          end
        end
        ZONES << sp
      end
    end
  end

  def remove_beetle(npc)
    ZONES[npc.variables.get_i32("zoneIndex", 0)].remove_spawn(npc)
    npc.delete_me
  end

  private class Zone < L2Territory
    @banned_zones : Array(Zone)?

    def initialize
      super(1)
    end

    def random_point
      loc = super
      while loc && inside_banned_zone?(loc)
        loc = super
      end
      loc
    end

    def add_banned_zone(zone)
      (@banned_zones ||= [] of Zone) << zone
    end

    private def inside_banned_zone?(loc)
      return false unless tmp = @banned_zones
      tmp.any? { |z| z.inside?(loc.x, loc.y) }
    end
  end

  private class SpawnZone
    include Loggable

    @zones = [] of Zone
    @spawn = Concurrent::Array(L2Npc).new

    initializer max_npc_count : Int32, index : Int32

    def add_zone(zone)
      @zones << zone
    end

    def remove_spawn(npc)
      @spawn.delete_first(npc)
    end

    def refresh_spawn
      while @spawn.size < @max_npc_count
        if loc = @zones.sample(random: Rnd).random_point
          sp = L2Spawn.new(18804)
          sp.heading = rand(65535)
          sp.x = loc.x
          sp.y = loc.y
          sp.z = GeoData.get_spawn_height(loc)

          npc = sp.do_spawn
          npc.no_random_walk = true
          npc.immobilized = true
          npc.invul = true
          npc.core_ai_disabled = true
          npc.script_value = 5
          npc.variables["zoneIndex"] = @index
          @spawn << npc
        end
      end
    rescue e
      error e
    end

    def refresh_shots
      @spawn.each do |npc|
        val = npc.script_value
        if val == 5
          npc.delete_me
          @spawn.delete_first(npc)
        else
          npc.script_value = val &+ 1
        end
      end
    end
  end

  def to_s(io : IO)
    io << {{@type.stringify}}
  end
end
