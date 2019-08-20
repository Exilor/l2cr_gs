require "./interfaces/spawn_listener"

require "../data_tables/npc_personal_ai_data"
require "./actor/instance/*"

class L2Spawn
  # include Identifiable
  include Positionable
  # include Namable
  include Loggable

  private SPAWN_LISTENERS = [] of SpawnListener

  @maximum_count = 0
  @current_count = 0
  @do_respawn = false
  @last_spawn_points : Hash(Int32, Location)?
  @constructor : L2Npc.class = L2Npc
  getter template
  getter spawned_npcs = [] of L2Npc
  getter spawn_territory : NpcSpawnTerritory?
  property name : String?
  property location : Location = Location.new(0, 0, 0, 0, 0)
  property scheduled_count : Int32 = 0
  property location_id : Int32 = 0
  property respawn_min_delay : Int32 = 0
  property respawn_max_delay : Int32 = 0
  property global_map_id : Int32 = 0
  property area_name : String?
  property? custom : Bool = false
  property? no_rnd_walk : Bool = false

  def initialize(@template : L2NpcTemplate)
    {% begin %}
      @constructor =
      case "#{template.type}Instance"
      {% for sub in L2Npc.all_subclasses.reject &.abstract? %}
        when {{sub.stringify}}
          {{sub}}
      {% end %}
      else
        raise "No constructor for #{template.type.inspect} found."
      end
    {% end %}
  end

  def self.new(id : Int) : self
    new(NpcData[id])
  end

  def id : Int32
    @template.id
  end

  def amount : Int32
    @maximum_count
  end

  def amount=(@maximum_count : Int32)
  end

  def get_location(obj : L2Object?) : Location
    if !@last_spawn_points || !obj || !@last_spawn_points.not_nil!.has_key?(obj.l2id)
      @location
    else
      @last_spawn_points.not_nil![obj.l2id]
    end
  end

  def x : Int32
    @location.x
  end

  def y : Int32
    @location.y
  end

  def z : Int32
    @location.z
  end

  def x=(x : Int32)
    @location.x = x
  end

  def y=(y : Int32)
    @location.y = y
  end

  def z=(z : Int32)
    @location.z = z
  end

  def get_x(obj) : Int32
    get_location(obj).x
  end

  def get_y(obj) : Int32
    get_location(obj).y
  end

  def get_z(obj) : Int32
    get_location(obj).z
  end

  def heading : Int32
    @location.heading
  end

  def heading=(val : Int32)
    @location.heading = val
  end

  def instance_id : Int32
    @location.instance_id
  end

  def instance_id=(id : Int32)
    @location.instance_id = id
  end

  def set_xyz(loc : Locatable)
    set_xyz(*loc.xyz)
  end

  def set_xyz(x : Int32, y : Int32, z : Int32)
    @location.x = x
    @location.y = y
    @location.z = z
  end

  def decrease_count(old : L2Npc)
    return if @current_count <= 0

    @current_count -= 1
    # debug "#decrease_count 1: about to delete #{old}"
    @spawned_npcs.delete_first(old)
    # debug "#decrease_count 2: about to delete #{old.l2id}"
    @last_spawn_points.try &.delete(old.l2id)

    if @do_respawn && @scheduled_count + @current_count < @maximum_count
      @scheduled_count += 1

      if respawn_random?
        delay = Rnd.rand(@respawn_min_delay..@respawn_max_delay)
      else
        delay = @respawn_min_delay
      end

      task = SpawnTask.new(self, old)
      ThreadPoolManager.schedule_general(task, delay)
    end
  end

  def init
    while @current_count < @maximum_count
      do_spawn
    end
    @do_respawn = @respawn_min_delay != 0
    @current_count
  end

  def spawn_one(val : Bool)
    do_spawn(val)
  end

  def respawn_enabled? : Bool
    @do_respawn
  end

  def start_respawn
    @do_respawn = true
  end

  def do_spawn?(summon_spawn : Bool = false)
    case @template.type
    when "L2Pet", "L2Decoy", "L2Trap"
      @current_count += 1
      return
    end

    npc = @constructor.new(@template)

    npc.instance_id = instance_id

    if summon_spawn
      npc.show_summon_animation = summon_spawn
    end

    NpcPersonalAIData.initialize_npc_parameters(npc, self, @name)

    initialize_npc_instance(npc)
  end

  def do_spawn(summon_spawn : Bool = false)
    do_spawn?(summon_spawn).not_nil!
  end

  def stop_respawn
    @do_respawn = false
  end

  def territory_based? : Bool
    !!@spawn_territory && @location.x == 0 && @location.y == 0
  end

  private def initialize_npc_instance(mob : L2Npc)
    new_x = new_y = new_z = 0

    if territory_based?
      new_x, new_y, new_z = @spawn_territory.not_nil!.random_point
    elsif x() == 0 || y() == 0
      if location_id() == 0
        return mob
      end

      location = TerritoryTable.get_random_point(location_id)

      if location
        new_x, new_y, new_z = location.xyz
      end
    else
      new_x, new_y, new_z = xyz
    end

    unless mob.flying?
      new_z = GeoData.get_spawn_height(new_x, new_y, new_z)
    end

    mob.stop_all_effects
    mob.dead = false
    mob.decayed = false

    mob.heal!

    if mob.has_variables?
      mob.variables.clear
    end

    mob.no_rnd_walk = @no_rnd_walk

    heading = heading()

    if heading == -1
      mob.heading = Rnd.rand(61_794)
    else
      mob.heading = heading
    end

    if mob.is_a?(L2Attackable)
      mob.champion = false
    end

    if Config.champion_enable && Config.champion_frequency > 0
      if mob.is_a?(L2MonsterInstance)
        if !@template.undying? && !mob.raid? && !mob.raid_minion?
          if Config.champ_min_lvl <= mob.level <= Config.champ_max_lvl
            if Config.champion_enable_in_instances || instance_id() == 0
              if Rnd.rand(100) < Config.champion_frequency
                mob.champion = true
              end
            end
          end
        end
      end
    end

    mob.summoner = nil
    mob.reset_summoned_npcs
    mob.spawn = self
    mob.spawn_me(new_x, new_y, new_z)

    L2Spawn.notify_npc_spawned(mob)

    @spawned_npcs << mob

    if points = @last_spawn_points
      points[mob.l2id] = Location.new(new_x, new_y, new_z)
    end

    @current_count += 1

    mob
  end

  def self.notify_npc_spawned(npc : L2Npc)
    SPAWN_LISTENERS.each &.npc_spawned(npc)
  end

  def respawn_delay=(delay : Int32)
    set_respawn_delay(delay)
  end

  def set_respawn_delay(delay : Int32, random_interval : Int32 = 0)
    if delay != 0
      min_delay = delay - random_interval
      max_delay = delay + random_interval

      @respawn_min_delay = Math.max(min_delay, 10) * 1000
      @respawn_max_delay = Math.max(max_delay, 10) * 1000
    else
      @respawn_min_delay = @respawn_max_delay = 0
    end
  end

  def respawn_delay : Int32
    (@respawn_min_delay + @respawn_max_delay) / 2
  end

  def respawn_random? : Bool
    @respawn_max_delay != @respawn_min_delay
  end

  def last_spawn : L2Npc?
    @spawned_npcs.last?
  end

  def respawn_npc(old : L2Npc)
    if @do_respawn
      old.refresh_id
      initialize_npc_instance(old)
    end
  end

  def spawn_territory=(territory : NpcSpawnTerritory?)
    @spawn_territory = territory
    @last_spawn_points = Hash(Int32, Location).new
  end

  def self.add_spawn_listener(listener : SpawnListener)
    SPAWN_LISTENERS << listener
  end

  def self.remove_spawn_listener(listener : SpawnListener)
    SPAWN_LISTENERS.delete(listener)
  end

  def self.notify_npc_spawned(npc : L2Npc)
    SPAWN_LISTENERS.each &.npc_spawned(npc)
  end

  private struct SpawnTask
    include Runnable

    initializer spawn: L2Spawn, old_npc: L2Npc

    def run
      @spawn.respawn_npc(@old_npc)
      @spawn.scheduled_count -= 1
    end
  end
end
