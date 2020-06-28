module AutoSpawnHandler
  extend self
  extend Loggable

  private DEFAULT_INITIAL_SPAWN = 30000 # 30 seconds after registration
  private DEFAULT_RESPAWN = 3600000 # 1 hour
  private DEFAULT_DESPAWN = 3600000 # 1 hour

  private REGISTERED_SPAWNS = Concurrent::Map(Int32, AutoSpawnInstance).new
  private RUNNING_SPAWNS = Concurrent::Map(Int32, TaskScheduler::Task).new

  @@active_state = true

  def load
    restore_spawn_data
  end

  def size : Int32
    REGISTERED_SPAWNS.size
  end

  def reload
    RUNNING_SPAWNS.each_value &.cancel
    REGISTERED_SPAWNS.each_value { |asi| remove_spawn(asi) }
    RUNNING_SPAWNS.clear
    REGISTERED_SPAWNS.clear
    restore_spawn_data
  end

  private def restore_spawn_data
    sql1 = "SELECT * FROM random_spawn ORDER BY groupId ASC"
    sql2 = "SELECT * FROM random_spawn_loc WHERE groupId=?"
    GameDB.each(sql1) do |rs|
      npc_id = rs.get_i32(:"npcId").to_u16!.to_i32
      initial_delay = rs.get_i32(:"initialDelay")
      respawn_delay = rs.get_i32(:"respawnDelay")
      despawn_delay = rs.get_i32(:"despawnDelay")
      inst = register_spawn(npc_id, initial_delay, respawn_delay, despawn_delay)
      inst.spawn_count = rs.get_i32(:"count")
      inst.broadcast = rs.get_bool(:"broadcastSpawn")
      inst.random_spawn = rs.get_bool(:"randomSpawn")

      GameDB.each(sql2, rs.get_i32(:"groupId")) do |rs2|
        x = rs2.get_i32("x")
        y = rs2.get_i32("y")
        z = rs2.get_i32("z")
        heading = rs2.get_i32("heading")
        inst.add_spawn_location(x, y, z, heading)
      end
    end
  rescue e
    error e
  end

  def register_spawn(npc_id : Int32, init_delay : Int32, respawn_delay : Int32, despawn_delay : Int32) : AutoSpawnInstance
    register_spawn(npc_id, nil, init_delay, respawn_delay, despawn_delay)
  end

  def register_spawn(npc_id : Int32, spawn_points, init_delay : Int32, respawn_delay : Int32, despawn_delay : Int32) : AutoSpawnInstance
    if init_delay < 0
      init_delay = DEFAULT_INITIAL_SPAWN
    end
    if respawn_delay < 0
      respawn_delay = DEFAULT_RESPAWN
    end

    if despawn_delay < 0
      despawn_delay = DEFAULT_DESPAWN
    end

    new_spawn = AutoSpawnInstance.new(npc_id, init_delay, respawn_delay, despawn_delay)

    spawn_points.try &.each { |sp| new_spawn.add_spawn_location(sp) }

    new_id = IdFactory.next
    new_spawn.l2id = new_id
    REGISTERED_SPAWNS[new_id] = new_spawn

    set_spawn_active(new_spawn, true)

    new_spawn
  end

  def remove_spawn(l2id : Int32)
    remove_spawn(REGISTERED_SPAWNS[l2id])
  end

  def remove_spawn(sp : AutoSpawnInstance)
    RUNNING_SPAWNS.delete(sp.l2id).try &.cancel
  end

  def set_spawn_active(sp : AutoSpawnInstance?, active : Bool)
    return unless sp

    l2id = sp.l2id

    if spawn_registered?(l2id)
      if active
        _as = AutoSpawner.new(l2id)
        if sp.despawn_delay > 0
          spawn_task = ThreadPoolManager.schedule_effect_at_fixed_rate(_as, sp.init_delay, sp.respawn_delay)
        else
          spawn_task = ThreadPoolManager.schedule_effect(_as, sp.init_delay)
        end
        RUNNING_SPAWNS[l2id] = spawn_task
      else
        ad = AutoDespawner.new(l2id)
        RUNNING_SPAWNS.delete(l2id).try &.cancel
        ThreadPoolManager.schedule_effect(ad, 0)
      end

      sp.spawn_active = active
    end
  end

  def all_active=(active : Bool)
    return if @@active_state == active
    REGISTERED_SPAWNS.each_value { |sp| set_spawn_active(sp, active) }
    @@active_state = active
  end

  def get_time_to_next_spawn(sp : AutoSpawnInstance) : Int64
    l2id = sp.l2id
    if spawn_registered?(l2id)
      delay = RUNNING_SPAWNS[l2id]?.try &.delay
      return delay ? Time.s_to_ms(delay) : 0i64
    end

    -1i64
  end

  def get_auto_spawn_instance?(id : Int32, is_l2id : Bool) : AutoSpawnInstance?
    if is_l2id
      if spawn_registered?(id)
        REGISTERED_SPAWNS[id]
      end
    else
      REGISTERED_SPAWNS.find_value { |sp| sp.id == id }
    end
  end

  def get_auto_spawn_instance(id : Int32, is_l2id : Bool) : AutoSpawnInstance
    unless inst = get_auto_spawn_instance?(id, is_l2id)
      raise "No auto spawn instance with id #{id} found"
    end

    inst
  end

  def get_auto_spawn_instances(npc_id : Int32) : Array(AutoSpawnInstance)
    REGISTERED_SPAWNS.local_each_value.select { |sp| sp.id == npc_id }.to_a
  end

  def spawn_registered?(l2id : Int32) : Bool
    REGISTERED_SPAWNS.has_key?(l2id)
  end

  def spawn_registered?(inst : AutoSpawnInstance) : Bool
    REGISTERED_SPAWNS.has_value?(arg)
  end

  private struct AutoSpawner
    include Loggable

    initializer l2id : Int32

    def call
      sp = REGISTERED_SPAWNS[@l2id]
      return unless sp.spawn_active?
      location_list = sp.location_list
      if location_list.empty?
        return
      end
      location_count = location_list.size
      location_index = Rnd.rand(location_count)

      unless sp.random_spawn?
        location_index = sp.last_loc_index + 1
        if location_index == location_count
          location_index = 0
        end
        sp.last_loc_index = location_index
      end

      x = location_list[location_index].x
      y = location_list[location_index].y
      z = location_list[location_index].z
      heading = location_list[location_index].heading

      new_spawn = L2Spawn.new(sp.id)
      new_spawn.x, new_spawn.y, new_spawn.z = x, y, z
      if heading != -1
        new_spawn.heading = heading
      end
      new_spawn.amount = sp.spawn_count
      if sp.despawn_delay == 0
        new_spawn.respawn_delay = sp.respawn_delay
      end

      SpawnTable.add_new_spawn(new_spawn, false)

      if sp.spawn_count == 1
        npc_inst = new_spawn.do_spawn
        # debug "Spawned #{npc_inst}."
        npc_inst.set_xyz(*npc_inst.xyz)
        sp.add_npc_instance(npc_inst)
      else
        sp.spawn_count.times do |i|
          npc_inst = new_spawn.do_spawn
          # debug "Spawned #{npc_inst} (#{i})."
          npc_inst.set_xyz(npc_inst.x + Rnd.rand(50), npc_inst.y + Rnd.rand(50), npc_inst.z)
          sp.add_npc_instance(npc_inst)
        end
      end

      if npc_inst
        nearest_town = MapRegionManager.get_closest_town_name(npc_inst)
        if sp.broadcasting?
          Broadcast.to_all_online_players("The #{npc_inst.name} has spawned near #{nearest_town}.")
        end
      end

      if sp.despawn_delay > 0
        ad = AutoDespawner.new(@l2id)
        ThreadPoolManager.schedule_ai(ad, sp.despawn_delay - 1000)
      end
    rescue e
      error e
    end
  end

  private struct AutoDespawner
    include Loggable

    initializer l2id : Int32

    def call
      unless sp = REGISTERED_SPAWNS[@l2id]?
        warn { "No spawn registered for l2id #{@l2id}." }
        return
      end

      sp.npc_instance_list.each do |npc_inst|
        npc_inst.delete_me
        SpawnTable.delete_spawn(npc_inst.spawn, false)
        sp.remove_npc_instance(npc_inst)
      end
    rescue e
      error e
    end
  end

  class AutoSpawnInstance
    @spawn_index = 0
    @broadcast_announcement = false

    getter id
    getter location_list = Concurrent::Array(Location).new
    getter npc_instance_list = Concurrent::LinkedList(L2Npc).new
    property l2id : Int32 = 0
    property init_delay : Int32
    property respawn_delay : Int32
    property despawn_delay : Int32
    property spawn_count : Int32 = 1
    property last_loc_index : Int32 = -1
    property? spawn_active : Bool = false
    property? random_spawn : Bool = false

    initializer id : Int32, init_delay : Int32, respawn_delay : Int32,
      despawn_delay : Int32

    def add_npc_instance(npc : L2Npc)
      @npc_instance_list << npc
    end

    def remove_npc_instance(npc : L2Npc)
      @npc_instance_list.delete(npc)
    end

    def spawns : Array(L2Spawn)
      @npc_instance_list.map &.spawn
    end

    def broadcast=(val : Bool)
      @broadcast_announcement = val
    end

    def broadcasting? : Bool
      @broadcast_announcement
    end

    def add_spawn_location(x : Int32, y : Int32, z : Int32, heading : Int32)
      @location_list << Location.new(x, y, z, heading)
    end

    def add_spawn_location(xyz : Indexable(Int32))
      x, y, z = xyz.values_at(0, 1, 2)
      loc = Location.new(x, y, z, -1)
      @location_list << loc
    end

    def remove_spawn_location(loc_index : Int32)
      @location_list.delete_at(loc_index)
    end
  end
end
