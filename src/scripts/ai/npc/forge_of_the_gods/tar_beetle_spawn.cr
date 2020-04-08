require "../../../../models/l2_territory"

class TarBeetleSpawn
  include XMLReader

  private ZONES = [] of SpawnZone
  private REFRESH_SPAWN_TASK = -> { ZONES.each &.refresh_spawn }
  private REFRESH_SHOTS_TASK = -> { ZONES.each &.refresh_shots }

  @spawn_task : Scheduler::PeriodicTask?
  @shot_task : Scheduler::PeriodicTask?

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

  private def parse_document(doc, file)
    doc.find_element("list") do |d|
      d.find_element("spawnZone") do |r|
        npc_count = r["maxNpcCount"].to_i
        sp = SpawnZone.new(npc_count, ZONES.size)
        r.find_element("zone") do |b|
          min_z = b["minZ"].to_i
          max_z = b["maxZ"].to_i
          zone = Zone.new
          b.each_element do |c|
            if c.name == "point"
              x = c["x"].to_i
              y = c["y"].to_i
              zone.add(x, y, min_z, max_z, 0)
            elsif c.name == "bannedZone"
              banned_zone = Zone.new
              b_min_z = c["minZ"].to_i
              b_max_z = c["maxZ"].to_i
              c.find_element("point") do |f|
                x = f["x"].to_i
                y = f["y"].to_i
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
          npc.disable_core_ai(true)
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
          npc.script_value = val + 1
        end
      end
    end
  end
end
