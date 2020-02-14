require "../models/entity/instance"
require "../models/instance_zone/instance_world"

module InstanceManager
  extend self
  extend XMLReader

  private ADD_INSTANCE_TIME = "INSERT INTO character_instance_time (charId,instanceId,time) values (?,?,?) ON DUPLICATE KEY UPDATE time=?"
  private RESTORE_INSTANCE_TIMES = "SELECT instanceId,time FROM character_instance_time WHERE charId=?"
  private DELETE_INSTANCE_TIME = "DELETE FROM character_instance_time WHERE charId=? AND instanceId=?"

  private INSTANCES = Concurrent::Map(Int32, Instance).new
  private INSTANCE_WORLDS = Concurrent::Map(Int32, InstanceWorld).new
  private INSTANCE_ID_NAMES = {} of Int32 => String
  private PLAYER_INSTANCE_TIMES = Concurrent::Map(Int32, IHash(Int32, Int64)).new

  @@dynamic = 300_000

  def load
    INSTANCES[-1] = Instance.new(-1, "multiverse")
    info "Multiverse instance created."
    INSTANCES[0] = Instance.new(0, "universe")
    info "Universe instance created."
    INSTANCE_ID_NAMES.clear
    parse_datapack_file("instancenames.xml")
    info { "Loaded #{INSTANCE_ID_NAMES.size} instance names." }
  end

  def get_instance_time(pc_l2id : Int32, id : Int32) : Int64
    unless PLAYER_INSTANCE_TIMES.has_key?(pc_l2id)
      restore_instance_times(pc_l2id)
    end
    PLAYER_INSTANCE_TIMES[pc_l2id].fetch(id, -1i64)
  end

  def get_all_instance_times(pc_l2id : Int32) : IHash(Int32, Int64)
    unless PLAYER_INSTANCE_TIMES.has_key?(pc_l2id)
      restore_instance_times(pc_l2id)
    end
    PLAYER_INSTANCE_TIMES[pc_l2id]
  end

  def set_instance_time(pc_l2id : Int32, id : Int32, time : Int64)
    # debug "set_instance_time instance id: #{id}, time: #{time}."
    unless PLAYER_INSTANCE_TIMES.has_key?(pc_l2id)
      restore_instance_times(pc_l2id)
    end

    begin
      GameDB.exec(ADD_INSTANCE_TIME, pc_l2id, id, time, time)
      PLAYER_INSTANCE_TIMES[pc_l2id][id] = time
    rescue e
      error "Could not insert character instance data."
      error e
    end
  end

  def delete_instance_time(pc_l2id : Int32, id : Int32)
    GameDB.exec(DELETE_INSTANCE_TIME, pc_l2id, id)
    PLAYER_INSTANCE_TIMES[id]?.try &.delete(id)
  rescue e
    error "Could not delete character instance data."
    error e
  end

  def restore_instance_times(pc_l2id : Int32)
    return if PLAYER_INSTANCE_TIMES.has_key?(pc_l2id)

    PLAYER_INSTANCE_TIMES[pc_l2id] = Concurrent::Map(Int32, Int64).new

    GameDB.each(RESTORE_INSTANCE_TIMES, pc_l2id) do |rs|
      id = rs.get_i32("instanceId")
      time = rs.get_i64("time")
      if time < Time.ms
        delete_instance_time(pc_l2id, id)
      else
        PLAYER_INSTANCE_TIMES[pc_l2id][id] = time
      end
    end
  rescue e
    error "Could not delete character instance time data."
    error e
  end

  def get_instance_id_name(id : Int32) : String
    INSTANCE_ID_NAMES.fetch(id, "UnkownInstance")
  end

  private def parse_document(doc, file)
    doc.find_element("list") do |n|
      n.find_element("instance") do |d|
        id = d["id"].to_i
        name = d["name"]
        INSTANCE_ID_NAMES[id] = name
      end
    end
  end

  def add_world(world : InstanceWorld)
    INSTANCE_WORLDS[world.instance_id] = world
  end

  def get_world(id : Int32) : InstanceWorld?
    INSTANCE_WORLDS[id]?
  end

  def get_player_world(pc : L2PcInstance) : InstanceWorld?
    INSTANCE_WORLDS.find_value &.allowed?(pc.l2id)
  end

  def destroy_instance(id : Int32)
    return unless id > 0
    return unless instance = INSTANCES[id]?
    instance.remove_npcs
    instance.remove_players
    instance.remove_doors
    instance.cancel_timer
    INSTANCES.delete(id)
    INSTANCE_WORLDS.delete(id)
  end

  def get_instance(id : Int32) : Instance?
    INSTANCES[id]?
  end

  def get_player_instance(l2id : Int32) : Int32
    INSTANCES.find_value(&.includes?(l2id)).try &.id || 0
  end

  def create_instance(id : Int32) : Bool
    return false if get_instance(id)
    instance = Instance.new(id)
    INSTANCES[id] = instance
    true
  end

  def create_instance_from_template(id : Int32, template : String) : Bool
    return false if get_instance(id)
    INSTANCES[id] = instance = Instance.new(id)
    instance.load_instance_template(template)
    true
  end

  def create_dynamic_instance(template : String?) : Int32
    while get_instance(@@dynamic)
      @@dynamic += 1
      if @@dynamic == Int32::MAX
        warn { "More than #{Int32::MAX - 300_000} instances have been created." }
        @@dynamic = 300_000
      end
    end
    instance = Instance.new(@@dynamic)
    INSTANCES[@@dynamic] = instance
    if template
      instance.load_instance_template(template)
    end
    @@dynamic
  end

  def instances : IHash(Int32, Instance)
    INSTANCES
  end
end
