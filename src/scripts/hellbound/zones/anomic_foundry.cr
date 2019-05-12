class Scripts::AnomicFoundry < AbstractNpcAI
  # NPCs
  private LABORER = 22396
  private FOREMAN = 22397
  private LESSER_EVIL = 22398
  private GREATER_EVIL = 22399
  # Misc
  private ATTACK_INDEX = {} of Int32 => Int32
  # npc_id, x, y, z, heading, max count
  private SPAWNS = {
    {LESSER_EVIL,  27883, 248613, -3209, -13248,  5},
    {LESSER_EVIL,  26142, 246442, -3216,   7064,  5},
    {LESSER_EVIL,  27335, 246217, -3668,  -7992,  5},
    {LESSER_EVIL,  28486, 245913, -3698,      0, 10},
    {GREATER_EVIL, 28684, 244118, -3700, -22560, 10},
  }
  private SPAWNED = Slice.new(5, 0)

  @respawn_time = 60000
  @respawn_min = 20000
  @respawn_max = 300000

  def initialize
    super(self.class.simple_name, "hellbound/AI/Zones")

    add_aggro_range_enter_id(LABORER)
    add_attack_id(LABORER)
    add_kill_id(LABORER, LESSER_EVIL, GREATER_EVIL)
    add_spawn_id(LABORER, LESSER_EVIL, GREATER_EVIL)
    add_teleport_id(LABORER, LESSER_EVIL, GREATER_EVIL)
    start_quest_timer("make_spawn_1", @respawn_time, nil, nil)
  end

  def on_adv_event(event, npc, player)
    if event.casecmp?("make_spawn_1")
      if HellboundEngine.level >= 10
        idx = rand(3)
        if SPAWNED[idx] < SPAWNS[idx][5]
          tmp = SPAWNS[idx]
          add_spawn(tmp[0], tmp[1], tmp[2], tmp[3], tmp[4], false, 0, false)
          @respawn_time += 10000
        end
        start_quest_timer("make_spawn_1", @respawn_time, nil, nil)
      end
    elsif event.casecmp?("make_spawn_2")
      if SPAWNED[4] < SPAWNS[4][5]
        tmp = SPAWNS[4]
        add_spawn(tmp[0], tmp[1], tmp[2], tmp[3], tmp[4], false, 0, false)
      end
    elsif event.casecmp?("return_laborer")
      if npc && npc.alive?
        npc.as(L2Attackable).return_home
      end
    elsif event.casecmp?("reset_respawn_time")
      @respawn_time = 60000
    end

    super
  end

  def on_aggro_range_enter(npc, player, is_summon)
    if rand(10000) < 2000
      request_help(npc, player, 500, FOREMAN)
      request_help(npc, player, 500, LESSER_EVIL)
      request_help(npc, player, 500, GREATER_EVIL)
    end

    super
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    atk_idx = ATTACK_INDEX[npc.l2id]? || 0
    if atk_idx == 0
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::ENEMY_INVASION_HURRY_UP)
      cancel_quest_timer("return_laborer", npc, nil)
      start_quest_timer("return_laborer", 60000, npc, nil)

      if @respawn_time > @respawn_min
        @respawn_time -= 5000
      elsif @respawn_time <= @respawn_min
        unless get_quest_timer("reset_respawn_time", nil, nil)
          start_quest_timer("reset_respawn_time", 600000, nil, nil)
        end
      end
    end

    if rand(10000) < 2000
      atk_idx += 1
      ATTACK_INDEX[npc.l2id] = atk_idx
      request_help(npc, attacker, 1000 * atk_idx, FOREMAN)
      request_help(npc, attacker, 1000 * atk_idx, LESSER_EVIL)
      request_help(npc, attacker, 1000 * atk_idx, GREATER_EVIL)
      if rand(10) < 1
        x = npc.x + rand(-800..800)
        y = npc.y + rand(-800..800)
        loc = Location.new(x, y, npc.z, npc.heading)
        npc.set_intention(AI::MOVE_TO, loc)
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if get_spawn_group(npc) >= 0
      SPAWNED[get_spawn_group(npc)] -= 1
      SpawnTable.delete_spawn(npc.spawn, false)
    elsif npc.id == LABORER
      if rand(10000) < 8000
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::PROCESS_SHOULDNT_BE_DELAYED_BECAUSE_OF_ME)
        if @respawn_time < @respawn_max
          @respawn_time += 10000
        elsif @respawn_time >= @respawn_max &&
          unless get_quest_timer("reset_respawn_time", nil, nil)
            start_quest_timer("reset_respawn_time", 600000, nil, nil)
          end
        end
      end
      ATTACK_INDEX.delete(npc.l2id)
    end

    super
  end

  def on_spawn(npc)
    SpawnTable.add_new_spawn(npc.spawn, false)
    if get_spawn_group(npc) >= 0
      SPAWNED[get_spawn_group(npc)] += 1
    end

    if npc.id == LABORER
      npc.no_rnd_walk = true
    end

    super
  end

  def on_teleport(npc)
    if get_spawn_group(npc) >= 0 && get_spawn_group(npc) <= 2
      SPAWNED[get_spawn_group(npc)] -= 1
      SpawnTable.delete_spawn(npc.spawn, false)
      npc.schedule_despawn(100)
      if SPAWNED[3] < SPAWNS[3][5]
        tmp = SPAWNS[3]
        add_spawn(tmp[0], tmp[1], tmp[2], tmp[3], tmp[4], false, 0, false)
      end
    elsif get_spawn_group(npc) == 3
      start_quest_timer("make_spawn_2", @respawn_time * 2, nil, nil)
      SPAWNED[3] -= 1
      SpawnTable.delete_spawn(npc.spawn, false)
      npc.schedule_despawn(100)
    end
  end

  private def get_spawn_group(npc)
    coord_x = npc.spawn.x
    coord_y = npc.spawn.y
    npc_id = npc.id

    5.times do |i|
      tmp = SPAWNS[i]
      if tmp[0] == npc_id && tmp[1] == coord_x && tmp[2] == coord_y
        return i
      end
    end

    -1
  end

  # Zoey76: TODO: This should be done with onFactionCall(..)
  private def request_help(requester, agressor, range, helper_id)
    SpawnTable.get_spawns(helper_id).each do |sp|
      monster = sp.last_spawn.as?(L2MonsterInstance)
      if monster && agressor && monster.alive? && agressor.alive?
        if monster.inside_radius?(requester, range, true, false)
          monster.add_damage_hate(agressor, 0, 1000)
        end
      end
    end
  end
end
