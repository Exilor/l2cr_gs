class Scripts::Orfen < AbstractNpcAI
  private POS = {
    Location.new(43728, 17220, -4342),
    Location.new(55024, 17368, -5412),
    Location.new(53504, 21248, -5486),
    Location.new(53248, 24576, -5262)
  }

  private TEXT = {
    NpcString::S1_STOP_KIDDING_YOURSELF_ABOUT_YOUR_OWN_POWERLESSNESS,
    NpcString::S1_ILL_MAKE_YOU_FEEL_WHAT_TRUE_FEAR_IS,
    NpcString::YOURE_REALLY_STUPID_TO_HAVE_CHALLENGED_ME_S1_GET_READY,
    NpcString::S1_DO_YOU_THINK_THATS_GOING_TO_WORK
  }

  private ORFEN = 29014
  # private RAIKEL = 29015
  private RAIKEL_LEOS = 29016
  # private RIBA = 29017
  private RIBA_IREN = 29018

  private MINIONS = Concurrent::Array(L2Attackable).new
  private ALIVE = 0
  private DEAD = 1

  # Skills
  private PARALYSIS = SkillHolder.new(4064)
  private NPC_MORTAL_BLOW = SkillHolder.new(4067, 4)
  private ORFEN_HEAL = SkillHolder.new(4516)

  @zone : L2BossZone
  @teleported = false

  def initialize
    super(self.class.simple_name, "ai/individual")

    @zone = GrandBossManager.get_zone(POS[0]).not_nil!
    mobs = {ORFEN, RAIKEL_LEOS, RIBA_IREN}
    register_mobs(mobs)
    unless info = GrandBossManager.get_stats_set(ORFEN)
      raise "StatsSet for Orfen not found"
    end
    status = GrandBossManager.get_boss_status(ORFEN)

    if status == DEAD
      # load the unlock date and time for Orfen from DB
      temp = info.get_i64("respawn_time") - Time.ms
      # if Orfen is locked until a certain time, mark it so and start the unlock timer
      # the unlock time has not yet expired.
      if temp > 0
        start_quest_timer("orfen_unlock", temp, nil, nil)
      else
        # the time has already expired while the server was offline. Immediately spawn Orfen.
        i = Rnd.rand(10)
        if i < 4
          loc = POS[1]
        elsif i < 7
          loc = POS[2]
        else
          loc = POS[3]
        end
        orfen = add_spawn(ORFEN, loc, false, 0).as(L2GrandBossInstance)
        GrandBossManager.set_boss_status(ORFEN, ALIVE)
        spawn_boss(orfen)
      end
    else
      loc_x = info.get_i32("loc_x")
      loc_y = info.get_i32("loc_y")
      loc_z = info.get_i32("loc_z")
      heading = info.get_i32("heading")
      hp = info.get_i32("currentHP").to_f
      mp = info.get_i32("currentMP").to_f
      orfen = add_spawn(ORFEN, loc_x, loc_y, loc_z, heading, false, 0).as(L2GrandBossInstance)
      orfen.set_current_hp_mp(hp, mp)
      spawn_boss(orfen)
    end
  end

  def set_spawn_point(npc, index)
    npc.as(L2Attackable).clear_aggro_list
    npc.intention = AI::IDLE
    sp = npc.spawn
    sp.location = POS[index]
    npc.tele_to_location(POS[index], false)
  end

  def spawn_boss(npc)
    GrandBossManager.add_boss(npc)
    npc.broadcast_packet(Music::BS01_A_7000.packet)
    start_quest_timer("check_orfen_pos", 10000, npc, nil, true)
    # Spawn minions
    x = npc.x
    y = npc.y
    mob = add_spawn(RAIKEL_LEOS, x + 100, y + 100, npc.z, 0, false, 0).as(L2Attackable)
    mob.raid_minion = true
    MINIONS << mob
    mob = add_spawn(RAIKEL_LEOS, x + 100, y - 100, npc.z, 0, false, 0).as(L2Attackable)
    mob.raid_minion = true
    MINIONS << mob
    mob = add_spawn(RAIKEL_LEOS, x - 100, y + 100, npc.z, 0, false, 0).as(L2Attackable)
    mob.raid_minion = true
    MINIONS << mob
    mob = add_spawn(RAIKEL_LEOS, x - 100, y - 100, npc.z, 0, false, 0).as(L2Attackable)
    mob.raid_minion = true
    MINIONS << mob
    start_quest_timer("check_minion_loc", 10000, npc, nil, true)
  end

  def on_adv_event(event, npc, player)
    if event.casecmp?("orfen_unlock")
      i = Rnd.rand(10)
      if i < 4
        loc = POS[1]
      elsif i < 7
        loc = POS[2]
      else
        loc = POS[3]
      end
      orfen = add_spawn(ORFEN, loc, false, 0).as(L2GrandBossInstance)
      GrandBossManager.set_boss_status(ORFEN, ALIVE)
      spawn_boss(orfen)
    elsif event.casecmp?("check_orfen_pos")
      npc = npc.not_nil!
      if (@teleported && npc.current_hp > npc.max_hp * 0.95) || (!@zone.inside_zone?(npc) && !@teleported)
        set_spawn_point(npc, Rnd.rand(3) + 1)
        @teleported = false
      elsif @teleported && !@zone.inside_zone?(npc)
        set_spawn_point(npc, 0)
      end
    elsif event.casecmp?("check_minion_loc")
      npc = npc.not_nil!
      MINIONS.each do |mob|
        unless npc.inside_radius?(mob, 3000, false, false)
          mob.tele_to_location(npc.location)
          npc.as(L2Attackable).clear_aggro_list
          npc.intention = AI::IDLE
        end
      end
    elsif event.casecmp?("despawn_minions")
      MINIONS.each &.decay_me
      MINIONS.clear
    elsif event.casecmp?("spawn_minion")
      npc = npc.not_nil!
      mob = add_spawn(RAIKEL_LEOS, *npc.xyz, 0, false, 0).as(L2Attackable)
      mob.raid_minion = true
      MINIONS << mob
    end

    super
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    if npc.id == ORFEN
      original_caster = is_summon ? (caster.summon || caster) : caster
      if skill.effect_point > 0 && Rnd.rand(5) == 0 && npc.inside_radius?(original_caster, 1000, false, false)
        say = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc.id, TEXT.sample)
        say.add_string_parameter(caster.name)
        npc.broadcast_packet(say)
        original_caster.tele_to_location(npc.location)
        npc.target = original_caster
        npc.do_cast(PARALYSIS)
      end
    end

    super
  end

  def on_faction_call(npc, caller, attacker, is_summon)
    if caller.nil? || npc.nil? || npc.casting_now?
      return super
    end
    npc_id = npc.id
    caller_id = caller.id
    if npc_id == RAIKEL_LEOS && Rnd.rand(20) == 0
      npc.target = attacker
      npc.do_cast(NPC_MORTAL_BLOW)
    elsif npc_id == RIBA_IREN
      chance = 1
      if caller_id == ORFEN
        chance = 9
      end
      if caller_id != RIBA_IREN && caller.current_hp < caller.max_hp / 2.0
        if Rnd.rand(10) < chance
          npc.intention = AI::IDLE
          npc.target = caller
          npc.do_cast(ORFEN_HEAL)
        end
      end
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    npc_id = npc.id
    if npc_id == ORFEN
      if !@teleported && npc.current_hp - damage < npc.max_hp / 2
        @teleported = true
        set_spawn_point(npc, 0)
      elsif npc.inside_radius?(attacker, 1000, false, false)
        if !npc.inside_radius?(attacker, 300, false, false) && Rnd.rand(10) == 0
          say = NpcSay.new(npc.l2id, Say2::NPC_ALL, npc_id, TEXT.sample)
          say.add_string_parameter(attacker.name)
          npc.broadcast_packet(say)
          attacker.tele_to_location(npc.location)
          npc.target = attacker
          npc.do_cast(PARALYSIS)
        end
      end
    elsif npc_id == RIBA_IREN
      if !npc.casting_now? && npc.current_hp - damage < npc.max_hp / 2.0
        npc.target = attacker
        npc.do_cast(ORFEN_HEAL)
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if npc.id == ORFEN
      npc.broadcast_packet(Music::BS02_D_7000.packet)
      GrandBossManager.set_boss_status(ORFEN, DEAD)
      # Calculate Min and Max respawn times randomly.
      respawn_time = Config.orfen_spawn_interval + Rnd.rand(-Config.orfen_spawn_random..Config.orfen_spawn_random)
      respawn_time *= 3600000
      start_quest_timer("orfen_unlock", respawn_time, nil, nil)
      # also save the respawn time so that the info is maintained past reboots
      unless info = GrandBossManager.get_stats_set(ORFEN)
        raise "StatsSet for orfen not found"
      end
      info["respawn_time"] = Time.ms + respawn_time
      GrandBossManager.set_stats_set(ORFEN, info)
      cancel_quest_timer("check_minion_loc", npc, nil)
      cancel_quest_timer("check_orfen_pos", npc, nil)
      start_quest_timer("despawn_minions", 20000, nil, nil)
      cancel_quest_timers("spawn_minion")
    elsif GrandBossManager.get_boss_status(ORFEN) == ALIVE
      if npc.id == RAIKEL_LEOS
        MINIONS.delete_first(npc)
        start_quest_timer("spawn_minion", 360000, npc, nil)
      end
    end

    super
  end
end
