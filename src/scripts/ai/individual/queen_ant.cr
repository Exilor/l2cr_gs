class Scripts::QueenAnt < AbstractNpcAI
  private QUEEN = 29001
  private LARVA = 29002
  private NURSE = 29003
  private GUARD = 29004
  private ROYAL = 29005

  private MOBS = {QUEEN, LARVA, NURSE, GUARD, ROYAL}

  private OUST_LOC_1 = Location.new(-19480, 187344, -5600)
  private OUST_LOC_2 = Location.new(-17928, 180912, -5520)
  private OUST_LOC_3 = Location.new(-23808, 182368, -5600)

  private QUEEN_X = -21610
  private QUEEN_Y = 181594
  private QUEEN_Z = -5734

  # QUEEN Status Tracking
  private ALIVE = 0 # Queen Ant is spawned.
  private DEAD = 1 # Queen Ant has been killed.

  private HEAL1 = SkillHolder.new(4020)
  private HEAL2 = SkillHolder.new(4024)

  private NURSES = Concurrent::Array(L2MonsterInstance).new

  @zone : L2BossZone?
  @queen : L2MonsterInstance?
  @larva : L2MonsterInstance?

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_spawn_id(MOBS)
    add_kill_id(MOBS)
    add_aggro_range_enter_id(MOBS)
    add_faction_call_id(NURSE)

    @zone = GrandBossManager.get_zone(QUEEN_X, QUEEN_Y, QUEEN_Z).not_nil!
    info = GrandBossManager.get_stats_set(QUEEN).not_nil!
    status = GrandBossManager.get_boss_status(QUEEN)
    if status == DEAD
      temp = info.get_i64("respawn_time") - Time.ms
      if temp > 0
        start_quest_timer("queen_unlock", temp, nil, nil)
      else
        queen = add_spawn(QUEEN, QUEEN_X, QUEEN_Y, QUEEN_Z, 0, false, 0).as(L2GrandBossInstance)
        GrandBossManager.set_boss_status(QUEEN, ALIVE)
        spawn_boss(queen)
      end
    else
      loc_x = info.get_i32("loc_x")
      loc_y = info.get_i32("loc_y")
      loc_z = info.get_i32("loc_z")
      heading = info.get_i32("heading")
      hp = info.get_i32("currentHP")
      mp = info.get_i32("currentMP")
      unless @zone.not_nil!.inside_zone?(loc_x, loc_y, loc_z)
        loc_x = QUEEN_X
        loc_y = QUEEN_Y
        loc_z = QUEEN_Z
      end
      queen = add_spawn(QUEEN, loc_x, loc_y, loc_z, heading, false, 0).as(L2GrandBossInstance)
      queen.set_current_hp_mp(hp.to_f, mp.to_f)
      spawn_boss(queen)
    end
  end

  private def spawn_boss(npc : L2GrandBossInstance)
    GrandBossManager.add_boss(npc)
    if Rnd.rand(100) < 33
      @zone.not_nil!.move_players_to(OUST_LOC_1)
    elsif Rnd.rand(100) < 50
      @zone.not_nil!.move_players_to(OUST_LOC_2)
    else
      @zone.not_nil!.move_players_to(OUST_LOC_3)
    end
    GrandBossManager.add_boss(npc)
    start_quest_timer("action", 10_000, npc, nil, true)
    start_quest_timer("heal", 1000, nil, nil, true)
    npc.broadcast_packet(Music::BS01_A_10000.packet)
    @queen = npc
    @larva = add_spawn(LARVA, -21600, 179482, -5846, Rnd.rand(360), false, 0).as(L2MonsterInstance)
  end

  def on_adv_event(event, npc, pc)
    if event.casecmp?("heal")
      queen, larva = @queen, @larva
      larva_need_heal = !!larva && larva.current_hp < larva.max_hp
      queen_need_heal = !!queen && queen.current_hp < queen.max_hp
      NURSES.each do |nurse|
        if nurse.nil? || nurse.dead? || nurse.casting_now?
          next
        end

        not_casting = !nurse.intention.cast?
        if larva_need_heal
          if nurse.target != larva || not_casting
            nurse.target = larva
            nurse.use_magic(Rnd.bool ? HEAL1.skill : HEAL2.skill)
          end

          next
        end
        if queen_need_heal
          if nurse.leader == larva
            next
          end

          if nurse.target != queen || not_casting
            nurse.target = queen
            nurse.use_magic(HEAL1.skill)
          end

          next
        end

        if not_casting && nurse.target
          nurse.target = nil
        end
      end
    elsif event.casecmp?("action") && npc
      if Rnd.rand(3) == 0
        if Rnd.rand(2) == 0
          npc.broadcast_social_action(3)
        else
          npc.broadcast_social_action(4)
        end
      end
    elsif event.casecmp?("queen_unlock")
      queen = add_spawn(QUEEN, QUEEN_X, QUEEN_Y, QUEEN_Z, 0, false, 0).as(L2GrandBossInstance)
      GrandBossManager.set_boss_status(QUEEN, ALIVE)
      spawn_boss(queen)
    end

    super
  end

  def on_spawn(npc)
    mob = npc.as(L2MonsterInstance)
    case npc.id
    when LARVA
      mob.immobilized = true
      mob.mortal = false
      mob.raid_minion = true
    when NURSE
      mob.disable_core_ai(true)
      mob.raid_minion = true
      NURSES << mob
    when ROYAL, GUARD
      mob.raid_minion = true
    end

    super
  end

  def on_faction_call(npc, caller, attacker, is_summon)
    if caller.nil? || npc.nil?
      return super
    end

    if !npc.casting_now? && !npc.intention.cast?
      if caller.current_hp < caller.max_hp
        npc.target = caller
        npc.as(L2Attackable).use_magic(HEAL1.skill)
      end
    end

    nil
  end

  def on_aggro_range_enter(npc, pc, is_summon)
    if npc.nil? || (pc.gm? && pc.invisible?)
      return
    end

    if is_summon
      is_mage = false
      character = pc.summon
    else
      is_mage = pc.mage_class?
      character = pc
    end

    unless character
      return
    end

    if !Config.raid_disable_curse && character.level &- npc.level > 8
      curse = nil
      if is_mage
        if !character.muted? && Rnd.rand(4) == 0
          curse = CommonSkill::RAID_CURSE.skill
        end
      else
        if !character.paralyzed? && Rnd.rand(4) == 0
          curse = CommonSkill::RAID_CURSE2.skill
        end
      end

      if curse
        npc.broadcast_packet(MagicSkillUse.new(npc, character, curse.id, curse.level, 300, 0))
        curse.apply_effects(npc, character)
      end

      npc.as(L2Attackable).stop_hating(character)
      return
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    npc_id = npc.id
    if npc_id == QUEEN
      npc.broadcast_packet(Music::BS02_D_10000.packet)
      GrandBossManager.set_boss_status(QUEEN, DEAD)
      min = -Config.queen_ant_spawn_random
      max = Config.queen_ant_spawn_random
      respawn_time = Config.queen_ant_spawn_interval + Rnd.rand(min..max)
      respawn_time *= 3_600_000
      start_quest_timer("queen_unlock", respawn_time, nil, nil)
      cancel_quest_timer("action", npc, nil)
      cancel_quest_timer("heal", nil, nil)

      info = GrandBossManager.get_stats_set(QUEEN).not_nil!
      info["respawn_time"] = Time.ms + respawn_time
      GrandBossManager.set_stats_set(QUEEN, info)
      NURSES.clear
      @larva.try &.delete_me
      @larva = nil
      @queen = nil
    elsif (queen = @queen) && !queen.looks_dead?
      if npc_id == ROYAL
        mob = npc.as(L2MonsterInstance)
        if leader = mob.leader
          leader.minion_list.on_minion_die(mob, (280 + Rnd.rand(40)) * 1000)
        end
      elsif npc_id == NURSE
        mob = npc.as(L2MonsterInstance)
        NURSES.delete_first(mob)
        if leader = mob.leader
          leader.minion_list.on_minion_die(mob, 10000)
        end
      end
    end

    super
  end
end
