module GrandBossManager
  extend self
  extend Loggable

  private DELETE_GRAND_BOSS_LIST = "DELETE FROM grandboss_list"
  private INSERT_GRAND_BOSS_LIST = "INSERT INTO grandboss_list (player_id,zone) VALUES (?,?)"
  private UPDATE_GRAND_BOSS_DATA = "UPDATE grandboss_data set loc_x = ?, loc_y = ?, loc_z = ?, heading = ?, respawn_time = ?, currentHP = ?, currentMP = ?, status = ? where boss_id = ?"
  private UPDATE_GRAND_BOSS_DATA2 = "UPDATE grandboss_data set status = ? where boss_id = ?"

  private BOSSES = Hash(Int32, L2GrandBossInstance).new
  private STORED_INFO = {} of Int32 => StatsSet
  private BOSS_STATUS = Hash(Int32, Int32).new
  private ZONES = Hash(Int32, L2BossZone).new

  def load
    sql = "SELECT * from grandboss_data ORDER BY boss_id"
    GameDB.each(sql) do |rs|
      info = StatsSet.new
      boss_id = rs.get_i32("boss_id")
      info["loc_x"] = rs.get_i32("loc_x")
      info["loc_y"] = rs.get_i32("loc_y")
      info["loc_z"] = rs.get_i32("loc_z")
      info["heading"] = rs.get_i32("heading")
      info["respawn_time"] = rs.get_i64("respawn_time")
      info["currentHP"] = rs.get_f64("currentHP").to_i32
      info["currentMP"] = rs.get_f64("currentMP").to_i32
      status = rs.get_i32("status")
      BOSS_STATUS[boss_id] = status
      STORED_INFO[boss_id] = info
      if status == 0
        info { "#{NpcData[boss_id].name} (#{boss_id}) is alive." }
      else
        info { "#{NpcData[boss_id].name} (#{boss_id}) is dead." }
      end
      if status > 0
        time = Time.from_ms(rs.get_i64("respawn_time"))
        info { "Next spawn date of #{NpcData[boss_id].name} is #{time}." }
      end
    end

    info { "Loaded #{STORED_INFO.size} bosses." }

    if STORED_INFO.empty?
      warn "No bosses were loaded"
    end

    ThreadPoolManager.schedule_general_at_fixed_rate(self, 5 * 60 * 1000, 5 * 60 * 1000)

    init_zones
  end

  def call
    store_me
  end

  def init_zones
    zones = {} of Int32 => Array(Int32)
    ZONES.each_key { |zone_id| zones[zone_id] = [] of Int32 }

    sql = "SELECT * from grandboss_list ORDER BY player_id"
    GameDB.each(sql) do |rs|
      id = rs.get_i32("player_id")
      zone_id = rs.get_i32("zone")
      zones[zone_id] << id
    end
    info { "Initialized #{ZONES.size} Grand Boss zones." }
    ZONES.each do |id, zone|
      zone.allowed_players = zones[id]
    end
    zones.clear
  end

  def add_zone(zone : L2BossZone)
    ZONES[zone.id] = zone
  end

  def get_zone(zone_id : Int32) : L2BossZone?
    ZONES[zone_id]?
  end

  def get_zone(char : L2Character) : L2BossZone?
    ZONES.find_value &.character_in_zone?(char)
  end

  def get_zone(loc : Location) : L2BossZone?
    ZONES.find_value &.inside_zone?(*loc.xyz)
  end

  def get_zone(x : Int32, y : Int32, z : Int32) : L2BossZone?
    ZONES.find_value &.inside_zone?(x, y, z)
  end

  def get_zone!(*args) : L2BossZone
    unless zone = get_zone(*args)
      raise "No L2BossZone found with args #{args}"
    end

    zone
  end

  def in_zone?(zone_type : String, obj : L2Object) : Bool
    return false unless temp = get_zone(*obj.xyz)
    temp.name.casecmp?(zone_type)
  end

  def in_zone?(pc : L2PcInstance) : Bool
    !!get_zone(*pc.xyz)
  end

  def get_boss_status(boss_id : Int32) : Int32?
    BOSS_STATUS[boss_id]?
  end

  def set_boss_status(boss_id : Int32, status : Int32)
    BOSS_STATUS[boss_id] = status
    info { "Updated: #{NpcData[boss_id].name} (#{boss_id}) status to #{status}." }
    update_db(boss_id, true)
  end

  def add_boss(boss : L2GrandBossInstance?)
    if boss
      BOSSES[boss.id] = boss
    end
  end

  def get_boss(boss_id : Int32) : L2GrandBossInstance?
    BOSSES[boss_id]?
  end

  def get_stats_set(boss_id : Int32) : StatsSet?
    STORED_INFO[boss_id]?
  end

  def set_stats_set(boss_id : Int32, info : StatsSet)
    STORED_INFO[boss_id] = info
    update_db(boss_id, false)
  end

  def store_me
    GameDB.exec(DELETE_GRAND_BOSS_LIST)
    ZONES.each do |key, value|
      list = value.allowed_players # Int32[]
      next if list.empty?
      list.each do |player|
        GameDB.exec(
          INSERT_GRAND_BOSS_LIST,
          player,
          key
        )
      end
    end
    STORED_INFO.each do |key, info|
      boss = BOSSES[key]?
      if boss.nil?
        GameDB.exec(
          UPDATE_GRAND_BOSS_DATA2,
          BOSS_STATUS[key],
          key
        )
      else
        GameDB.exec(
          UPDATE_GRAND_BOSS_DATA,
          boss.x,
          boss.y,
          boss.z,
          boss.heading,
          info.get_i64("respawn_time"),
          boss.dead? ? boss.max_hp : boss.current_hp,
          boss.dead? ? boss.max_mp : boss.current_mp,
          BOSS_STATUS[key],
          key
        )
      end
    end
  rescue e
    error e
    false
  else
    true
  end

  private def update_db(boss_id : Int32, status_only : Bool)
    boss = BOSSES[boss_id]?
    info = STORED_INFO[boss_id]?

    if status_only || boss.nil? || info.nil?
      GameDB.exec(
        UPDATE_GRAND_BOSS_DATA2,
        BOSS_STATUS[boss_id],
        boss_id
      )
    else
      boss = boss.not_nil!
      info = info.not_nil!

      GameDB.exec(
        UPDATE_GRAND_BOSS_DATA,
        boss.x,
        boss.y,
        boss.z,
        boss.heading,
        info.get_i64("respawn_time"),
        boss.dead? ? boss.max_hp : boss.current_hp,
        boss.dead? ? boss.max_mp : boss.current_mp,
        BOSS_STATUS[boss_id],
        boss_id
      )
    end
  rescue e
    error e
  end

  def clean_up
    store_me
    BOSSES.clear
    STORED_INFO.clear
    BOSS_STATUS.clear
    ZONES.clear
  end

  def zones
    ZONES
  end
end
