module RaidBossSpawnManager
  extend self
  extend Loggable

  private EILHALDER_VON_HELLMANN = 25328
  private BOSSES      = Concurrent::Map(Int32, L2RaidBossInstance).new
  private SPAWNS      = Concurrent::Map(Int32, L2Spawn).new
  private SCHEDULES   = Concurrent::Map(Int32, TaskScheduler::DelayedTask).new
  private STORED_INFO = Concurrent::Map(Int32, StatsSet).new

  enum Status : UInt8
    ALIVE
    DEAD
    UNDEFINED
  end

  def load
    BOSSES.clear
    SPAWNS.clear
    SCHEDULES.clear
    STORED_INFO.clear

    sql = "SELECT * FROM raidboss_spawnlist ORDER BY boss_id"
    GameDB.each(sql) do |rs|
      dat = L2Spawn.new(rs.get_i32(:"boss_id"))
      dat.x = rs.get_i32(:"loc_x")
      dat.y = rs.get_i32(:"loc_y")
      dat.z = rs.get_i32(:"loc_z")
      dat.amount = rs.get_i32(:"amount")
      dat.heading = rs.get_i32(:"heading")
      respawn_delay = rs.get_i32(:"respawn_delay")
      respawn_random = rs.get_i32(:"respawn_random")
      dat.set_respawn_delay(respawn_delay, respawn_random)
      respawn_time = rs.get_i64(:"respawn_time")
      current_hp = rs.get_f64(:"currentHP")
      current_mp = rs.get_f64(:"currentMP")
      add_new_spawn(dat, respawn_time, current_hp, current_mp, false)
    end

    info { "Loaded #{BOSSES.size} raid bosses." }
    info { "Scheduled #{SCHEDULES.size} tasks." }
  end

  def add_new_spawn(sp : L2Spawn, respawn_time : Int64, current_hp : Float64, current_mp : Float64, store_in_db : Bool)
    return if SPAWNS.has_key?(sp.id)

    boss_id = sp.id
    time = Time.ms

    SpawnTable.add_new_spawn(sp, false)

    if respawn_time == 0 || time > respawn_time
      if boss_id == EILHALDER_VON_HELLMANN
        raid_boss = DayNightSpawnManager.handle_boss(sp)
      else
        raid_boss = sp.do_spawn.as(L2RaidBossInstance)
      end

      if raid_boss
        raid_boss.current_hp = current_hp
        raid_boss.current_mp = current_mp
        raid_boss.raid_status = Status::ALIVE
        BOSSES[boss_id] = raid_boss
        info = StatsSet {
          "currentHP" => current_hp,
          "currentMP" => current_mp,
          "respawnTime" => 0i64
        }
        STORED_INFO[boss_id] = info
      end
    else
      spawn_time = respawn_time - Time.ms
      task = SpawnSchedule.new(boss_id)
      sch = ThreadPoolManager.schedule_general(task, spawn_time)
      SCHEDULES[boss_id] = sch
    end

    SPAWNS[boss_id] = sp

    if store_in_db
      sql = "INSERT INTO raidboss_spawnlist (boss_id,amount,loc_x,loc_y,loc_z,heading,respawn_time,currentHp,currentMp) VALUES(?,?,?,?,?,?,?,?,?)"
      GameDB.exec(
        sql,
        sp.id,
        sp.amount,
        sp.x,
        sp.y,
        sp.z,
        sp.heading,
        respawn_time,
        current_hp,
        current_mp
      )
    end
  end

  def get_raid_boss_status_id(id : Int32) : Status
    if temp = BOSSES[id]?
      temp.raid_status
    elsif SCHEDULES.has_key?(id)
      Status::DEAD
    else
      Status::UNDEFINED
    end
  end

  def notify_spawn_night_boss(raid : L2RaidBossInstance)
    info = StatsSet {
      "currentHP" => raid.current_hp,
      "currentMP" => raid.current_mp,
      "respawnTime" => 0
    }
    raid.raid_status = Status::ALIVE
    STORED_INFO[raid.id] = info
    info { "Spawning night raid boss #{raid.name}." }
    BOSSES[raid.id] = raid
  end

  def defined?(boss_id : Int32) : Bool
    SPAWNS.has_key?(boss_id)
  end

  def bosses : Interfaces::Map(Int32, L2RaidBossInstance)
    BOSSES
  end

  def spawns : Interfaces::Map(Int32, L2Spawn)
    SPAWNS
  end

  def stored_info : Interfaces::Map(Int32, StatsSet)
    STORED_INFO
  end

  def clean_up
    update_db

    BOSSES.clear

    unless SCHEDULES.empty?
      SCHEDULES.each_value &.cancel
      SCHEDULES.clear
    end

    STORED_INFO.clear
    SPAWNS.clear
  end

  private def update_db
    sql = "UPDATE raidboss_spawnlist SET respawn_time = ?, currentHP = ?, currentMP = ? WHERE boss_id = ?"
    GameDB.transaction do |tr|
      STORED_INFO.each do |boss_id, info|
        boss = BOSSES[boss_id]

        if boss.raid_status.alive?
          update_status(boss, false)
        end

        begin
          tr.exec(
            sql,
            info.get_i64("respawnTime"),
            info.get_f64("currentHP"),
            info.get_f64("currentMP"),
            boss_id
          )
        rescue e
          error e
        end
      end
    end
  end

  def update_status(boss : L2RaidBossInstance, is_dead : Bool)
    unless info = STORED_INFO[boss.id]?
      return
    end

    if is_dead
      boss.raid_status = Status::DEAD

      sp = boss.spawn
      min_delay = (sp.respawn_min_delay * Config.raid_min_respawn_multiplier).to_i
      max_delay = (sp.respawn_max_delay * Config.raid_max_respawn_multiplier).to_i
      delay = Rnd.rand(min_delay..max_delay)
      respawn_time = Time.ms + delay

      info["currentHP"] = boss.max_hp
      info["currentMP"] = boss.max_mp
      info["respawnTime"] = respawn_time

      if !SCHEDULES.has_key?(boss.id) && (min_delay > 0 || max_delay > 0)
        time = Time.from_ms(respawn_time)
        info { "Updated #{boss.name} respawn time to #{time}." }
        ss = SpawnSchedule.new(boss.id)
        task = ThreadPoolManager.schedule_general(ss, delay)
        SCHEDULES[boss.id] = task
        update_db
      end
    else
      boss.raid_status = Status::ALIVE
      info["currentHP"] = boss.current_hp
      info["currentMP"] = boss.current_mp
      info["respawnTime"] = 0i64
    end

    STORED_INFO[boss.id] = info
  end

  def delete_spawn(dat : L2Spawn?, update_db : Bool)
    return unless dat

    boss_id = dat.id
    unless SPAWNS.has_key?(boss_id)
      return
    end

    SpawnTable.delete_spawn(dat, false)
    SPAWNS.delete(boss_id)
    BOSSES.delete(boss_id)
    SCHEDULES.delete(boss_id).try &.cancel
    STORED_INFO.delete(boss_id)

    if update_db
      begin
        sql = "DELETE FROM raidboss_spawnlist WHERE boss_id=?"
        GameDB.exec(sql, boss_id)
      rescue e
        error e
      end
    end
  end

  private struct SpawnSchedule
    include Loggable

    initializer boss_id : Int32

    def call
      if @boss_id == EILHALDER_VON_HELLMANN
        raid = DayNightSpawnManager.handle_boss(SPAWNS[@boss_id])
      else
        raid = SPAWNS[@boss_id].do_spawn.as(L2RaidBossInstance)
      end

      if raid
        raid.raid_status = Status::ALIVE
        info = StatsSet {
          "currentHP" => raid.current_hp,
          "currentMP" => raid.current_mp,
          "respawnTime" => 0
        }
        raid.raid_status = Status::ALIVE
        STORED_INFO[raid.id] = info
        info { "Spawning raid boss #{raid.name}." }
        BOSSES[raid.id] = raid
      end
    end
  end
end
