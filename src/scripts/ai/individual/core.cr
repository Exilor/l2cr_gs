require "../../../enums/music"

class Scripts::Core < AbstractNpcAI
  private CORE = 29006
  private DEATH_KNIGHT = 29007
  private DOOM_WRAITH = 29008
  # DICOR = 29009
  # VALIDUS = 29010
  private SUSCEPTOR = 29011
  # PERUM = 29012
  # PREMO = 29013

  # Core Status Tracking :
  private ALIVE = 0 # Core is spawned.
  private DEAD = 1 # Core has been killed.

  private MINIONS = Concurrent::Array(L2Attackable).new

  @first_attacked = false

  def initialize
    super(self.class.simple_name, "ai/individual")

    register_mobs(CORE, DEATH_KNIGHT, DOOM_WRAITH, SUSCEPTOR)

    info = GrandBossManager.get_stats_set(CORE)
    status = GrandBossManager.get_boss_status(CORE)

    unless info && status
      warn "Core couldn't be loaded because its information was not found."
      return
    end

    if status == DEAD
      # load the unlock date and time for Core from DB
      temp = info.get_i64("respawn_time") - Time.ms
      # if Core is locked until a certain time, mark it so and start the unlock timer
      # the unlock time has not yet expired.
      if temp > 0
        start_quest_timer("core_unlock", temp, nil, nil)
      else
        # the time has already expired while the server was offline. Immediately spawn Core.
        core = add_spawn(CORE, 17726, 108915, -6480, 0, false, 0i64)
        GrandBossManager.set_boss_status(CORE, ALIVE)
        spawn_boss(core)
      end
    else
      test = load_global_quest_var("Core_Attacked")
      if test.casecmp?("true")
        @first_attacked = true
      end
      loc_x = info.get_i32("loc_x")
      loc_y = info.get_i32("loc_y")
      loc_z = info.get_i32("loc_z")
      heading = info.get_i32("heading")
      hp = info.get_i32("currentHP")
      mp = info.get_i32("currentMP")
      core = add_spawn(CORE, loc_x, loc_y, loc_z, heading, false, 0i64)
      core.set_current_hp_mp(hp.to_f64, mp.to_f64)
      spawn_boss(core)
    end
  end

  def save_global_data
    save_global_quest_var("Core_Attacked", @first_attacked.to_s)
  end

  def spawn_boss(npc)
    npc = npc.as(L2GrandBossInstance)
    GrandBossManager.add_boss(npc)
    npc.broadcast_packet(Music::BS01_A_10000.packet)

    # Spawn minions
    5.times do |i|
      x = 16800 + (i * 360)
      mob = add_spawn(DEATH_KNIGHT, x, 110000, npc.z, 280 + Rnd.rand(40), false, 0i64).as(L2Attackable)
      mob.raid_minion = true
      MINIONS << mob
      mob = add_spawn(DEATH_KNIGHT, x, 109000, npc.z, 280 + Rnd.rand(40), false, 0i64).as(L2Attackable)
      mob.raid_minion = true
      MINIONS << mob
      x2 = 16800 + (i * 600)
      mob = add_spawn(DOOM_WRAITH, x2, 109300, npc.z, 280 + Rnd.rand(40), false, 0i64).as(L2Attackable)
      mob.raid_minion = true
      MINIONS << mob
    end
    4.times do |i|
      x = 16800 + (i * 450)
      mob = add_spawn(SUSCEPTOR, x, 110300, npc.z, 280 + Rnd.rand(40), false, 0i64).as(L2Attackable)
      mob.raid_minion = true
      MINIONS << mob
    end
  end

  def on_adv_event(event, npc, player)
    case event.casecmp
    when "core_unlock"
      unless npc
        warn "No npc for #on_adv_event."
        return
      end

      core = add_spawn(CORE, 17726, 108915, -6480, 0, false, 0i64)
      GrandBossManager.set_boss_status(CORE, ALIVE)
      spawn_boss(core.as(L2GrandBossInstance))
    when "spawn_minion"
      unless npc
        warn "No npc for #on_adv_event."
        return
      end

      mob = add_spawn(npc.id, *npc.xyz, npc.heading, false, 0i64).as(L2Attackable)
      mob.raid_minion = true
      MINIONS << mob
    when "despawn_minions"
      MINIONS.each &.decay_me
      MINIONS.clear
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.id == CORE
      if @first_attacked
        if Rnd.rand(100) == 0
          npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::REMOVING_INTRUDERS))
        end
      else
        @first_attacked = true
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::A_NON_PERMITTED_TARGET_HAS_BEEN_DISCOVERED))
        npc.broadcast_packet(NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, NpcString::INTRUDER_REMOVAL_SYSTEM_INITIATED))
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if npc.id == CORE
      l2id = npc.l2id
      npc.broadcast_packet(Music::BS02_D_10000.packet)
      npc.broadcast_packet(NpcSay.new(l2id, Say2::NPC_ALL, npc.id, NpcString::A_FATAL_ERROR_HAS_OCCURRED))
      npc.broadcast_packet(NpcSay.new(l2id, Say2::NPC_ALL, npc.id, NpcString::SYSTEM_IS_BEING_SHUT_DOWN))
      npc.broadcast_packet(NpcSay.new(l2id, Say2::NPC_ALL, npc.id, NpcString::DOT_DOT_DOT_DOT_DOT_DOT))
      @first_attacked = false
      GrandBossManager.set_boss_status(CORE, DEAD)
      # Calculate Min and Max respawn times randomly.
      respawn_time = (Config.core_spawn_interval.to_i64 + Rnd.rand(-Config.core_spawn_random..Config.core_spawn_random)) * 3_600_000
      start_quest_timer("core_unlock", respawn_time, nil, nil)
      # also save the respawn time so that the info is maintained past reboots
      info = GrandBossManager.get_stats_set(CORE).not_nil!
      info["respawn_time"] = Time.ms + respawn_time
      GrandBossManager.set_stats_set(CORE, info)
      start_quest_timer("despawn_minions", 20_000, nil, nil)
      cancel_quest_timers("spawn_minion")
    elsif GrandBossManager.get_boss_status(CORE) == ALIVE && MINIONS.includes?(npc)
      MINIONS.delete_first(npc)
      start_quest_timer("spawn_minion", 60_000, npc, nil)
    end

    super
  end

  def on_spawn(npc)
    if npc.id == CORE
      npc.immobilized = true
    end

    super
  end
end
