require "./fort_siege"
require "./fort_updater"
require "../../enums/music"

class Fort < AbstractResidence
  include Loggable
  # Fortress Functions
  FUNC_TELEPORT = 1
  FUNC_RESTORE_HP = 2
  FUNC_RESTORE_MP = 3
  FUNC_RESTORE_EXP = 4
  FUNC_SUPPORT = 5

  @siege : FortSiege?
  @last_owned_time = Calendar.new
  @zone : L2SiegeZone?
  @fort_owner : L2Clan?
  @state = 0
  @castle_id = 0
  @functions = {} of Int32 => FortFunction
  @fort_updater = Slice(Scheduler::Task?).new(2, nil.as(Scheduler::Task?))
  @suspicious_merchant_spawned = false
  @siege_npcs = Concurrent::Array(L2Spawn).new
  @npc_commanders = Concurrent::Array(L2Spawn).new
  @special_envoys = Concurrent::Array(L2Spawn).new
  @envoy_castles = Hash(Int32, Int32).new(initial_capacity: 2)
  @available_castles = Set(Int32).new(1)
  getter doors = [] of L2DoorInstance
  getter fort_type = 0
  getter supply_lvl = 0
  getter! flag_pole : L2StaticObjectInstance?
  property siege_date : Calendar = Calendar.new

  def initialize(fort_id : Int32)
    super

    load
    load_flag_poles
    if owner_clan?
      self.visible_flag = true
      load_functions
    end
    init_residence_zone
    init_npcs
    init_siege_npcs
    init_npc_commanders
    spawn_npc_commanders
    init_special_envoys
    if owner_clan? && fort_state == 0
      spawn_special_envoys
    end
  end

  def get_function(type : Int32) : FortFunction?
    @functions[type]?
  end

  def end_of_siege(clan : L2Clan)
    ThreadPoolManager.execute_ai(EndFortressSiege.new(self, clan))
  end

  def banish_foreigners
    residence_zone.banish_foreigners(owner_clan.id)
  end

  def in_zone?(x : Int32, y : Int32, z : Int32) : Bool
    zone.inside_zone?(x, y, z)
  end

  def zone : L2SiegeZone
    unless @zone
      ZoneManager.get_all_zones(L2SiegeZone) do |zone|
        if zone.siege_l2id == residence_id
          @zone = zone
          break
        end
      end
    end

    @zone.as?(L2SiegeZone) ||
    raise("Couldn't find siege zone for fort with id #{residence_id}")
  end

  def residence_zone
    super.as(L2FortZone)
  end

  def get_distance(obj : L2Object) : Float64
    zone.get_distance_to_zone(obj)
  end

  def close_door(pc : L2PcInstance, door_id : Int32)
    open_close_door(pc, door_id, false)
  end

  def open_door(pc : L2PcInstance, door_id : Int32)
    open_close_door(pc, door_id, true)
  end

  def open_close_door(pc : L2PcInstance, door_id : Int32, open : Bool)
    if pc.clan? != owner_clan?
      return
    end

    if door = get_door(door_id)
      open ? door.open_me : door.close_me
    end
  end

  def remove_upgrade
    remove_door_upgrade
  end

  def set_owner(clan : L2Clan?, update_reputation : Bool) : Bool
    unless clan
      warn "Updating Fort owner with no clan."
      return false
    end

    sm = SystemMessage.the_fortress_battle_of_s1_has_finished
    sm.add_castle_id(residence_id)
    siege.announce_to_player(sm)

    old_owner = owner_clan?

    if old_owner && clan != old_owner
      update_clans_reputation(old_owner, true)
      begin
        if old_leader = old_owner.leader.player_instance?
          if old_leader.mount_type.wyvern?
            old_leader.dismount
          end
        end
      rescue e
        error e
      end
      remove_owner(true)
    end

    set_fort_state(0, 0)

    if clan.castle_id > 0
      siege.announce_to_player(SystemMessageId::NPCS_RECAPTURED_FORTRESS)
      return false
    end

    if update_reputation
      update_clans_reputation(clan, false)
    end

    spawn_special_envoys

    if clan.fort_id > 0
      FortManager.get_fort_by_owner!(clan).remove_owner(true)
    end

    self.supply_lvl = 0
    self.owner_clan = clan
    update_owner_in_db
    save_fort_variables

    if siege.in_progress?
      siege.end_siege
    end

    clan.each_online_player do |m|
      give_residential_skills(m)
      m.send_skill_list
    end

    true
  end

  def remove_owner(update_db : Bool)
    unless clan = owner_clan?
      return
    end

    clan.each_online_player do |m|
      remove_residential_skills(m)
      m.send_skill_list
    end
    clan.fort_id = 0
    clan.broadcast_to_online_members(PledgeShowInfoUpdate.new(clan))
    self.owner_clan = nil
    save_fort_variables
    remove_all_functions
    if update_db
      update_owner_in_db
    end
  end

  def raise_supply_lvl
    @supply_lvl += 1

    if @supply_lvl > Config.fs_max_supply_level
      @supply_lvl = Config.fs_max_supply_level
    end
  end

  def supply_lvl=(val : Int32)
    if val <= Config.fs_max_supply_level
      @supply_lvl = val
    end
  end

  def save_fort_variables
    GameDB.exec(
      "UPDATE fort SET supplyLvL=? WHERE id = ?",
      @supply_lvl,
      residence_id
    )
  rescue e
    error e
  end

  def visible_flag=(val : Bool)
    if flag = flag_pole?
      flag.mesh_index = val ? 1 : 0
    end
  end

  def reset_doors
    @doors.each do |door|
      if door.open?
        door.close_me
      end

      if door.dead?
        door.do_revive
      end

      if door.current_hp < door.max_hp
        door.max_hp!
      end
    end

    load_door_upgrade
  end

  def upgrade_door(door_id : Int32, hp : Int32, p_def : Int32, m_def : Int32)
    if door = get_door(door_id)
      door.current_hp = door.max_hp.to_f + hp
      save_door_upgrade(door_id, hp, p_def, m_def)
    end
  end

  private def load
    owner_id = 0
    sql = "SELECT * FROM fort WHERE id = ?"
    GameDB.each(sql, residence_id) do |rs|
      self.name = rs.get_string("name")

      date = Calendar.new
      date.ms = rs.get_i64("siegeDate")
      @siege_date = date
      date = Calendar.new
      date.ms = rs.get_i64("lastOwnedTime")
      @last_owned_time = date
      owner_id = rs.get_i32("owner")
      @fort_type = rs.get_i32("fortType")
      @state = rs.get_i32("state")
      @castle_id = rs.get_i32("castleId")
      @supply_lvl = rs.get_i32("supplyLvL")
    end

    if owner_id > 0
      clan = ClanTable.get_clan!(owner_id)
      clan.fort_id = residence_id
      self.owner_clan = clan
      run_count = owned_time // (Config.fs_update_frq * 60)
      initial = Time.ms - @last_owned_time.ms
      while initial > (Config.fs_update_frq * 60000)
        initial -= (Config.fs_update_frq * 60000)
      end
      initial = (Config.fs_update_frq * 60000) - initial
      if Config.fs_max_own_time <= 0 || owned_time < Config.fs_max_own_time * 3600
        @fort_updater[0] =
        ThreadPoolManager.schedule_general_at_fixed_rate(
          FortUpdater.new(self, clan, run_count, UpdaterType::PERIODIC_UPDATE),
          initial,
          Config.fs_update_frq * 60000
        )
        if Config.fs_max_own_time > 0
          @fort_updater[1] =
          ThreadPoolManager.schedule_general_at_fixed_rate(
            FortUpdater.new(self, clan, run_count, UpdaterType::MAX_OWN_TIME),
            3600000,
            3600000
          )
        end
      else
        @fort_updater[1] =
        ThreadPoolManager.schedule_general(
          FortUpdater.new(self, clan, 0, UpdaterType::MAX_OWN_TIME),
          60000,
        )
      end
    else
      self.owner_clan = nil
    end
  rescue e
    error e
  end

  private def load_functions
    sql = "SELECT * FROM fort_functions WHERE fort_id = ?"
    GameDB.each(sql, residence_id) do |rs|
      type = rs.get_i32("type")
      lvl = rs.get_i32("lvl")
      lease = rs.get_i32("lease")
      rate = rs.get_i64("rate")
      end_time = rs.get_i64("endTime")
      fn = FortFunction.new(self, type, lvl, lease, 0, rate, end_time, true)
      @functions[type] = fn
    end
  rescue e
    error e
  end

  def remove_function(type : Int32)
    sql = "DELETE FROM fort_functions WHERE fort_id=? AND type=?"
    GameDB.exec(sql, residence_id, type)
  rescue e
    error e
  end

  def remove_all_functions
    @functions.each_key { |id| remove_function(id) }
  end

  def update_functions(pc : L2PcInstance, type : Int32, lvl : Int32, lease : Int32, rate : Int64, add_new : Bool) : Bool
    if lease > 0
      unless pc.destroy_item_by_item_id("Consume", Inventory::ADENA_ID, lease, nil, true)
        return false
      end
    end

    if add_new
      @functions[type] = FortFunction.new(self, type, lvl, lease, 0, rate, 0, false)
    else
      if lvl == 0 && lease == 0
        remove_function(type)
      else
        diff_lease = lease - @functions[type].lease
        if diff_lease > 0
          @functions.delete(type)
          @functions[type] = FortFunction.new(self, type, lvl, lease, 0, rate, -1, false)
        else
          fn = @functions[type]
          fn.lease = lease
          fn.lvl = lvl
          fn.db_save
        end
      end
    end

    true
  rescue e
    error e
    false
  end

  def activate_instance
    load_door
  end

  private def load_door
    DoorData.doors.each do |door|
      if door.fort? && door.fort.residence_id == residence_id
        @doors << door
      end
    end
  end

  private def load_flag_poles
    StaticObjectData.static_objects.each do |obj|
      if obj.type == 3 && obj.name.starts_with?(name)
        @flag_pole = obj
        break
      end
    end

    unless @flag_pole
      raise "Can't find flag pole for fort #{self}"
    end
  end

  private def load_door_upgrade
    sql = "SELECT * FROM fort_doorupgrade WHERE fortId = ?"
    GameDB.each(sql, residence_id) do |rs|
      door_id = rs.get_i32("doorId")
      hp = rs.get_i32("hp")
      p_def = rs.get_i32("pDef")
      m_def = rs.get_i32("mDef")
      upgrade_door(door_id, hp, p_def, m_def)
    end
  rescue e
    error e
  end

  private def remove_door_upgrade
    sql = "DELETE FROM fort_doorupgrade WHERE fortId = ?"
    GameDB.exec(sql, residence_id)
  rescue e
    error e
  end

  private def save_door_upgrade(door_id : Int32, hp : Int32, p_def : Int32, m_def : Int32)
    sql = "INSERT INTO fort_doorupgrade (doorId, hp, pDef, mDef) VALUES (?,?,?,?)"
    GameDB.exec(sql, door_id, hp, p_def, m_def)
  rescue e
    error e
  end

  private def update_owner_in_db
    clan = owner_clan?
    clan_id = 0

    if clan
      clan_id = clan.id
      @last_owned_time.ms = Time.ms
    else
      @last_owned_time.ms = 0
    end

    begin
      sql = "UPDATE fort SET owner=?,lastOwnedTime=?,state=?,castleId=? WHERE id = ?"
      GameDB.exec(sql, clan_id, @last_owned_time.ms, 0, 0, residence_id)

      if clan
        clan.fort_id = residence_id
        sm = SystemMessage.s1_clan_is_victorious_in_the_fortress_battle_of_s2
        sm.add_string(clan.name)
        sm.add_castle_id(residence_id)
        L2World.players.each &.send_packet(sm)
        clan.broadcast_to_online_members(PledgeShowInfoUpdate.new(clan))
        clan.broadcast_to_online_members(Music::SIEGE_VICTORY.packet)
        @fort_updater[0].try &.cancel
        @fort_updater[1].try &.cancel
        @fort_updater[0] = ThreadPoolManager.schedule_general_at_fixed_rate(FortUpdater.new(self, clan, 0, UpdaterType::PERIODIC_UPDATE), Config.fs_update_frq * 60000, Config.fs_update_frq * 60000)
        if Config.fs_max_own_time > 0
          @fort_updater[1] = ThreadPoolManager.schedule_general_at_fixed_rate(FortUpdater.new(self, clan, 0, UpdaterType::MAX_OWN_TIME), 3600000, 3600000)
        end
      else
        @fort_updater[0].try &.cancel
        @fort_updater[1].try &.cancel
        @fort_updater[0] = nil
        @fort_updater[1] = nil
      end
    rescue e
      error e
    end
  end

  def owner_clan? : L2Clan?
    @fort_owner
  end

  def owner_clan=(clan : L2Clan?)
    self.visible_flag = !!clan
    @fort_owner = clan
  end

  def owner_clan : L2Clan
    owner_clan?.not_nil!
  end

  def get_door(door_id : Int32) : L2DoorInstance?
    if door_id <= 0
      return
    end

    doors.find { |door| door.id == door_id }
  end

  def siege
    @siege ||= FortSiege.new(self)
  end

  def owned_time : Int32
    time = @last_owned_time.ms
    if time == 0
      return 0
    end

    ((Time.ms - time) / 1000).to_i32
  end

  def time_until_rebel_army : Int32
    time = @last_owned_time.ms
    if time == 0
      return 0
    end

    (((time + (Config.fs_max_own_time * 3600000)) - Time.ms) / 1000).to_i32
  end

  def time_until_next_fort_update : Int64
    unless temp = @fort_updater[0]
      return 0i64
    end

    (temp.delay / 1000).to_i64
  end

  def update_clans_reputation(owner : L2Clan?, remove_points : Bool)
    if owner
      if remove_points
        owner.take_reputation_score(Config.lose_fort_points, true)
      else
        owner.add_reputation_score(Config.take_fort_points, true)
      end
    end
  end

  def fort_state : Int32
    @state
  end

  def set_fort_state(@state : Int32, @castle_id : Int32)
    sql = "UPDATE fort SET state=?,castleId=? WHERE id = ?"
    GameDB.exec(sql, fort_state, contracted_castle_id, residence_id)
  rescue e
    error e
  end

  def get_castle_id_by_ambassador(npc_id : Int32) : Int32
    @envoy_castles[npc_id]
  end

  def get_castle_by_ambassador(npc_id : Int32) : Castle?
    castle_id = get_castle_id_by_ambassador(npc_id)
    unless castle = CastleManager.get_castle_by_id(castle_id)
      raise "No castle found for ambassador with npc_id #{npc_id}"
    end

    castle
  end

  def contracted_castle_id : Int32
    @castle_id
  end

  def contracted_castle : Castle
    CastleManager.get_castle_by_id(contracted_castle_id).not_nil!
  end

  def border_fortress? : Bool
    @available_castles.size > 1
  end

  def fort_size : Int32
    fort_type == 0 ? 3 : 5
  end

  def spawn_suspicious_merchant
    if @suspicious_merchant_spawned
      return
    end

    @suspicious_merchant_spawned = true

    @siege_npcs.each do |sp|
      sp.do_spawn
      sp.start_respawn
    end
  end

  def despawn_suspicious_merchant
    unless @suspicious_merchant_spawned
      return
    end

    @suspicious_merchant_spawned = false

    @siege_npcs.each do |sp|
      sp.stop_respawn
      sp.last_spawn.not_nil!.delete_me
    end
  end

  def spawn_npc_commanders
    @npc_commanders.each do |sp|
      sp.do_spawn
      sp.start_respawn
    end
  end

  def despawn_npc_commanders
    @npc_commanders.each do |sp|
      sp.stop_respawn
      sp.last_spawn.not_nil!.delete_me
    end
  end

  def spawn_special_envoys
    @special_envoys.each &.do_spawn
  end

  private def init_npcs
    sql = "SELECT * FROM fort_spawnlist WHERE fortId = ? AND spawnType = ?"
    GameDB.each(sql, residence_id, 0) do |rs|
      sp = L2Spawn.new(rs.get_i32("npcId").to_u16!.to_i32)
      sp.amount = 1
      sp.x = rs.get_i32("x")
      sp.y = rs.get_i32("y")
      sp.z = rs.get_i32("z")
      sp.heading = rs.get_i32("heading")
      sp.respawn_delay = 60
      SpawnTable.add_new_spawn(sp, false)
      sp.do_spawn
      sp.start_respawn
    end
  rescue e
    error e
  end

  private def init_siege_npcs
    @siege_npcs.clear
    sql = "SELECT id, npcId, x, y, z, heading FROM fort_spawnlist WHERE fortId = ? AND spawnType = ? ORDER BY id"
    GameDB.each(sql, residence_id, 2) do |rs|
      sp = L2Spawn.new(rs.get_i32("npcId").to_u16!.to_i32)
      sp.amount = 1
      sp.x = rs.get_i32("x")
      sp.y = rs.get_i32("y")
      sp.z = rs.get_i32("z")
      sp.heading = rs.get_i32("heading")
      sp.respawn_delay = 60
      @siege_npcs << sp
    end
  rescue e
    error e
  end

  private def init_npc_commanders
    @npc_commanders.clear
    sql = "SELECT id, npcId, x, y, z, heading FROM fort_spawnlist WHERE fortId = ? AND spawnType = ? ORDER BY id"
    GameDB.each(sql, residence_id, 1) do |rs|
      sp = L2Spawn.new(rs.get_i32("npcId").to_u16!.to_i32)
      sp.amount = 1
      sp.x = rs.get_i32("x")
      sp.y = rs.get_i32("y")
      sp.z = rs.get_i32("z")
      sp.heading = rs.get_i32("heading")
      sp.respawn_delay = 60
      @npc_commanders << sp
    end
  rescue e
    error e
  end

  private def init_special_envoys
    @special_envoys.clear
    @envoy_castles.clear
    @available_castles.clear
    sql = "SELECT id, npcId, x, y, z, heading, castleId FROM fort_spawnlist WHERE fortId = ? AND spawnType = ? ORDER BY id"
    GameDB.each(sql, residence_id, 3) do |rs|
      castle_id = rs.get_i32("castleId")
      sp = L2Spawn.new(rs.get_i32("npcId").to_u16!.to_i32)
      sp.amount = 1
      sp.x = rs.get_i32("x")
      sp.y = rs.get_i32("y")
      sp.z = rs.get_i32("z")
      sp.heading = rs.get_i32("heading")
      sp.respawn_delay = 60
      @special_envoys << sp
      @envoy_castles[sp.id] = castle_id
      @available_castles << castle_id
    end
  end

  private def init_residence_zone
    ZoneManager.get_all_zones(L2FortZone) do |zone|
      if zone.residence_id == residence_id
        self.residence_zone = zone
        break
      end
    end
  end

  private struct EndFortressSiege
    include Loggable

    initializer fort : Fort, clan : L2Clan

    def call
      @fort.set_owner(@clan, true)
    rescue e
      error e
    end
  end

  class FortFunction
    include Loggable

    getter type, rate
    property lvl : Int32
    @in_debt = false

    def initialize(@fort : Fort, @type : Int32, @lvl : Int32, @fee : Int32, @temp_fee : Int32, @rate : Int64, @end_date : Int64, cwh : Bool)
      initialize_task(cwh)
    end

    def lease : Int32
      @fee
    end

    def lease=(@fee : Int32)
    end

    def end_time : Int64
      @end_date
    end

    def end_time=(@end_date : Int64)
    end

    private def initialize_task(cwh : Bool)
      unless @fort.owner_clan?
        return
      end

      time = Time.ms
      task = ->{ function_task(cwh) }

      if @end_date > time
        ThreadPoolManager.schedule_general(task, @end_date - time)
      else
        ThreadPoolManager.schedule_general(task, 0)
      end
    end

    private def function_task(cwh : Bool)
      unless clan = @fort.owner_clan?
        return
      end

      ware = clan.warehouse

      if ware.adena >= @fee || !cwh
        fee = @fee
        if end_time == -1
          fee = @temp_fee
        end
        self.end_time = Time.ms + rate
        if cwh
          ware.destroy_item_by_item_id("CS_function_fee", Inventory::ADENA_ID, fee.to_i64, nil, nil)
        end
        ThreadPoolManager.schedule_general(->{ function_task(true) }, rate)
      else
        @fort.remove_function(type)
      end
    rescue e
      error e
    end

    def db_save
      sql = "REPLACE INTO fort_functions (fort_id, type, lvl, lease, rate, endTime) VALUES (?,?,?,?,?,?)"
      GameDB.exec(
        sql,
        @fort.residence_id,
        type,
        lvl,
        lease,
        rate,
        end_time
      )
    rescue e
      error e
    end
  end
end
