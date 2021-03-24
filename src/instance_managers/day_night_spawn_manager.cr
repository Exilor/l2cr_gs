module DayNightSpawnManager
  extend self
  include Loggable

  private DAY_CREATURES = [] of L2Spawn
  private NIGHT_CREATURES = [] of L2Spawn
  private BOSSES = Concurrent::Map(L2Spawn, L2RaidBossInstance).new

  def add_day_creature(spawn_dat : L2Spawn)
    DAY_CREATURES << spawn_dat
  end

  def add_night_creature(spawn_dat : L2Spawn)
    NIGHT_CREATURES << spawn_dat
  end

  def spawn_day_creatures
    spawn_creatures(NIGHT_CREATURES, DAY_CREATURES, "night", "day")
  end

  def spawn_night_creatures
    spawn_creatures(DAY_CREATURES, NIGHT_CREATURES, "day", "night")
  end

  private def spawn_creatures(unspawn : Array(L2Spawn), do_spawn : Array(L2Spawn), unspawn_info : String, spawn_info : String)
    unless unspawn.empty?
      i = 0
      unspawn.each do |s|
        s.stop_respawn
        if last = s.last_spawn
          last.delete_me
          i &+= 1
        end
      end

      info { "Removed #{i} #{unspawn_info} creatures." }
    end

    i = 0
    do_spawn.each do |s|
      s.start_respawn
      s.do_spawn
      i &+= 1
    end
    info { "Spawned #{i} #{spawn_info} creatures." }
  rescue e
    error e
  end

  # custom: should be private but i want to call it from SendBypassBuildCmd
  def change_mode(night : Bool)
    return if NIGHT_CREATURES.empty? && DAY_CREATURES.empty? && BOSSES.empty?

    if night
      spawn_night_creatures
      special_night_boss(1)
    else
      spawn_day_creatures
      special_night_boss(0)
    end
  end

  def trim
    DAY_CREATURES.trim
    NIGHT_CREATURES.trim
  end

  def notify_change_mode
    change_mode(GameTimer.night?)
  rescue e
    error e
  end

  def clean_up
    BOSSES.clear
    DAY_CREATURES.clear
    NIGHT_CREATURES.clear
  end

  private def special_night_boss(night)
    BOSSES.each_key do |s|
      boss = BOSSES[s]?
      if boss.nil? && night
        boss = s.do_spawn.as(L2RaidBossInstance)
        RaidBossSpawnManager.notify_spawn_night_boss(boss)
        BOSSES[s] = boss
        next
      end

      next if boss.nil? && !night

      if boss && boss.id == 25328 && boss.raid_status.alive?
        handle_hellmans(boss, night)
      end

      return
    end
  rescue e
    error e
  end

  private def handle_hellmans(boss, night)
    if night
      unless boss.visible?
        boss.spawn_me
      end
      info "Spawning Hellmann raid boss."
    else
      boss.delete_me
      info "Deleting Hellmann raid boss."
    end
  end

  def handle_boss(spawn_dat : L2Spawn) : L2RaidBossInstance?
    if boss = BOSSES[spawn_dat]?
      return boss
    end

    if GameTimer.night?
      boss = spawn_dat.do_spawn.as(L2RaidBossInstance)
      BOSSES[spawn_dat] = boss
    end
  end
end
