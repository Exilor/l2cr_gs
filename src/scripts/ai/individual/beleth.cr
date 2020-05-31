class Scripts::Beleth < AbstractNpcAI
  private ALIVE = 0
  private INIT = 1
  private FIGHT = 2
  private DEAD = 3

  private REAL_BELETH = 29118
  private FAKE_BELETH = 29119
  private STONE_COFFIN = 32470
  private ELF = 29128
  private WHIRPOOL = 29125

  private BELETH_SPAWN = Location.new(16323, 213059, -9357, 49152)

  private BLEED = SkillHolder.new(5495)
  private FIREBALL = SkillHolder.new(5496)
  private HORN_OF_RISING = SkillHolder.new(5497)
  private LIGHTENING = SkillHolder.new(5499)

  private DOOR1 = 20240001
  private DOOR2 = 20240002
  private DOOR3 = 20240003

  private RING = ItemHolder.new(10314, 1)

  private MINIONS = Concurrent::Array(L2Npc).new

  @camera1 : L2Npc?
  @camera2 : L2Npc?
  @camera3 : L2Npc?
  @camera4 : L2Npc?
  @whirpool : L2Npc?
  @beleth : L2Npc?
  @priest : L2Npc?
  @stone : L2Npc?
  @killer : L2PcInstance?
  @allowed_l2id = 0
  @killed_count = 0
  @last_attack = 0i64
  @zone : L2ZoneType

  def initialize
    super(self.class.simple_name, "ai/individual")

    @zone = ZoneManager.get_zone_by_id(12018).not_nil!

    add_enter_zone_id(@zone.id)
    register_mobs(REAL_BELETH, FAKE_BELETH)
    add_start_npc(STONE_COFFIN)
    add_talk_id(STONE_COFFIN)
    add_first_talk_id(ELF)
    info = GrandBossManager.get_stats_set(REAL_BELETH).not_nil!
    status = GrandBossManager.get_boss_status(REAL_BELETH)
    if status == DEAD
      time = info.get_i64("respawn_time") - Time.ms
      if time > 0
        start_quest_timer("BELETH_UNLOCK", time, nil, nil)
      else
        GrandBossManager.set_boss_status(REAL_BELETH, ALIVE)
      end
    elsif status != ALIVE
      GrandBossManager.set_boss_status(REAL_BELETH, ALIVE)
    end
    DoorData.get_door(DOOR1).not_nil!.open_me
  end

  def on_adv_event(event, npc, pc)
    case event
    when "BELETH_UNLOCK"
      GrandBossManager.set_boss_status(REAL_BELETH, ALIVE)
      DoorData.get_door(DOOR1).not_nil!.open_me
    when "CAST"
      npc = npc.not_nil!
      if npc.alive? && !npc.casting_now?
        npc.set_intention(AI::ACTIVE)
        npc.do_cast(FIREBALL)
      end
    when "SPAWN1"
      @zone.characters_inside.each do |c|
        c.disable_all_skills
        c.invul = true
        c.immobilized = true
      end

      @camera1 = add_spawn(29120, Location.new(16323, 213142, -9357))
      @camera2 = add_spawn(29121, Location.new(16323, 210741, -9357))
      @camera3 = add_spawn(29122, Location.new(16323, 213170, -9357))
      @camera4 = add_spawn(29123, Location.new(16323, 214917, -9356))

      @zone.broadcast_packet(Music::BS07_A_10000.packet)
      @zone.broadcast_packet(SpecialCamera.new(@camera1.not_nil!, 400, 75, -25, 0, 2500, 0, 0, 1, 0, 0))
      @zone.broadcast_packet(SpecialCamera.new(@camera1.not_nil!, 400, 75, -25, 0, 2500, 0, 0, 1, 0, 0))

      start_quest_timer("SPAWN2", 300, nil, nil)
    when "SPAWN2"
      @zone.broadcast_packet(SpecialCamera.new(@camera1.not_nil!, 1800, -45, -45, 5000, 5000, 0, 0, 1, 0, 0))
      start_quest_timer("SPAWN3", 4900, nil, nil)
    when "SPAWN3"
      @zone.broadcast_packet(SpecialCamera.new(@camera1.not_nil!, 2500, -120, -45, 5000, 5000, 0, 0, 1, 0, 0))
      start_quest_timer("SPAWN4", 4900, nil, nil)
    when "SPAWN4"
      @zone.broadcast_packet(SpecialCamera.new(@camera2.not_nil!, 2200, 130, 0, 0, 1500, -20, 15, 1, 0, 0))
      start_quest_timer("SPAWN5", 1400, nil, nil)
    when "SPAWN5"
      @zone.broadcast_packet(SpecialCamera.new(@camera2.not_nil!, 2300, 100, 0, 2000, 4500, 0, 10, 1, 0, 0))
      start_quest_timer("SPAWN6", 2500, nil, nil)
    when "SPAWN6"
      door = DoorData.get_door(DOOR1).not_nil!
      door.close_me

      @zone.broadcast_packet(StaticObject.new(door, false))
      @zone.broadcast_packet(DoorStatusUpdate.new(door))

      start_quest_timer("SPAWN7", 1700, nil, nil)
    when "SPAWN7"
      @zone.broadcast_packet(SpecialCamera.new(@camera4.not_nil!, 1500, 210, 0, 0, 1500, 0, 0, 1, 0, 0))
      @zone.broadcast_packet(SpecialCamera.new(@camera4.not_nil!, 900, 255, 0, 5000, 6500, 0, 10, 1, 0, 0))
      start_quest_timer("SPAWN8", 6000, nil, nil)
    when "SPAWN8"
      @whirpool = add_spawn(WHIRPOOL, Location.new(16323, 214917, -9356))
      @zone.broadcast_packet(SpecialCamera.new(@camera4.not_nil!, 900, 255, 0, 0, 1500, 0, 10, 1, 0, 0))
      start_quest_timer("SPAWN9", 1000, nil, nil)
    when "SPAWN9"
      @zone.broadcast_packet(SpecialCamera.new(@camera4.not_nil!, 1000, 255, 0, 7000, 17000, 0, 25, 1, 0, 0))
      start_quest_timer("SPAWN10", 3000, nil, nil)
    when "SPAWN10"
      beleth = add_spawn(REAL_BELETH, Location.new(16321, 214211, -9352, 49369))
      beleth.disable_all_skills
      beleth.invul = true
      beleth.immobilized = true
      @beleth = beleth

      start_quest_timer("SPAWN11", 200, nil, nil)
    when "SPAWN11"
      @zone.broadcast_packet(SocialAction.new(@beleth.not_nil!.l2id, 1))

      6.times do |i|
        x = ((150 * Math.cos(i * 1.046666667)) + 16323).to_i
        y = ((150 * Math.sin(i * 1.046666667)) + 213059).to_i
        minion = add_spawn(FAKE_BELETH, Location.new(x, y, -9357, 49152))
        minion.show_summon_animation = true
        minion.decay_me

        MINIONS.push(minion)
      end

      start_quest_timer("SPAWN12", 6800, nil, nil)
    when "SPAWN12"
      @zone.broadcast_packet(SpecialCamera.new(@beleth.not_nil!, 0, 270, -5, 0, 4000, 0, 0, 1, 0, 0))
      start_quest_timer("SPAWN13", 3500, nil, nil)
    when "SPAWN13"
      @zone.broadcast_packet(SpecialCamera.new(@beleth.not_nil!, 800, 270, 10, 3000, 6000, 0, 0, 1, 0, 0))
      start_quest_timer("SPAWN14", 5000, nil, nil)
    when "SPAWN14"
      @zone.broadcast_packet(SpecialCamera.new(@camera3.not_nil!, 100, 270, 15, 0, 5000, 0, 0, 1, 0, 0))
      @zone.broadcast_packet(SpecialCamera.new(@camera3.not_nil!, 100, 270, 15, 0, 5000, 0, 0, 1, 0, 0))
      start_quest_timer("SPAWN15", 100, nil, nil)
    when "SPAWN15"
      @zone.broadcast_packet(SpecialCamera.new(@camera3.not_nil!, 100, 270, 15, 3000, 6000, 0, 5, 1, 0, 0))
      start_quest_timer("SPAWN16", 1400, nil, nil)
    when "SPAWN16"
      @beleth.not_nil!.tele_to_location(BELETH_SPAWN)
      start_quest_timer("SPAWN17", 200, nil, nil)
    when "SPAWN17"
      @zone.broadcast_packet(MagicSkillUse.new(@beleth.not_nil!, @beleth.not_nil!, 5532, 1, 2000, 0))
      start_quest_timer("SPAWN18", 2000, nil, nil)
    when "SPAWN18"
      @zone.broadcast_packet(SpecialCamera.new(@camera3.not_nil!, 700, 270, 20, 1500, 8000, 0, 0, 1, 0, 0))
      start_quest_timer("SPAWN19", 6900, nil, nil)
    when "SPAWN19"
      @zone.broadcast_packet(SpecialCamera.new(@camera3.not_nil!, 40, 260, 0, 0, 4000, 0, 0, 1, 0, 0))

      MINIONS.each do |fake_beleth|
        fake_beleth.spawn_me
        fake_beleth.disable_all_skills
        fake_beleth.invul = true
        fake_beleth.immobilized = true
      end

      start_quest_timer("SPAWN20", 3000, nil, nil)
    when "SPAWN20"
      @zone.broadcast_packet(SpecialCamera.new(@camera3.not_nil!, 40, 280, 0, 0, 4000, 5, 0, 1, 0, 0))
      start_quest_timer("SPAWN21", 3000, nil, nil)
    when "SPAWN21"
      @zone.broadcast_packet(SpecialCamera.new(@camera3.not_nil!, 5, 250, 5, 0, 13000, 20, 15, 1, 0, 0))
      start_quest_timer("SPAWN22", 1000, nil, nil)
    when "SPAWN22"
      @zone.broadcast_packet(SocialAction.new(@beleth.not_nil!.l2id, 3))
      start_quest_timer("SPAWN23", 4000, nil, nil)
    when "SPAWN23"
      @zone.broadcast_packet(MagicSkillUse.new(@beleth.not_nil!, @beleth.not_nil!, 5533, 1, 2000, 0))
      start_quest_timer("SPAWN24", 6800, nil, nil)
    when "SPAWN24"
      @beleth.not_nil!.delete_me
      @beleth = nil

      MINIONS.each &.delete_me
      MINIONS.clear

      @camera1.not_nil!.delete_me
      @camera2.not_nil!.delete_me
      @camera3.not_nil!.delete_me
      @camera4.not_nil!.delete_me

      @zone.characters_inside.each do |c|
        c.enable_all_skills
        c.invul = false
        c.immobilized = false
      end

      @last_attack = Time.ms

      start_quest_timer("CHECK_ATTACK", 60000, nil, nil)

      start_quest_timer("SPAWN25", 60000, nil, nil)
    when "SPAWN25"
      MINIONS.clear

      a = 0
      16.times do |i|
        a += 1

        x = ((650 * Math.cos(i * 0.39)) + 16323).to_i
        y = ((650 * Math.sin(i * 0.39)) + 213170).to_i

        npc = add_spawn(FAKE_BELETH, Location.new(x, y, -9357, 49152))
        MINIONS.push(npc)

        if a >= 2
          npc.overloaded = true
          a = 0
        end
      end

      xm = Slice.new(16, 0)
      ym = Slice.new(16, 0)
      4.times do |i|
        xm[i] = ((1700 * Math.cos((i * 1.57) + 0.78)) + 16323).to_i
        ym[i] = ((1700 * Math.sin((i * 1.57) + 0.78)) + 213170).to_i

        npc = add_spawn(FAKE_BELETH, Location.new(xm[i], ym[i], -9357, 49152))
        npc.immobilized = true

        MINIONS << npc
      end

      xm[4] = (xm[0] + xm[1]) // 2
      ym[4] = (ym[0] + ym[1]) // 2
      npc = add_spawn(FAKE_BELETH, Location.new(xm[4], ym[4], -9357, 49152))
      npc.immobilized = true
      MINIONS << npc
      xm[5] = (xm[1] + xm[2]) // 2
      ym[5] = (ym[1] + ym[2]) // 2
      npc = add_spawn(FAKE_BELETH, Location.new(xm[5], ym[5], -9357, 49152))
      npc.immobilized = true
      MINIONS << npc
      xm[6] = (xm[2] + xm[3]) // 2
      ym[6] = (ym[2] + ym[3]) // 2
      npc = add_spawn(FAKE_BELETH, Location.new(xm[6], ym[6], -9357, 49152))
      npc.immobilized = true
      MINIONS << npc
      xm[7] = (xm[3] + xm[0]) // 2
      ym[7] = (ym[3] + ym[0]) // 2
      npc = add_spawn(FAKE_BELETH, Location.new(xm[7], ym[7], -9357, 49152))
      npc.immobilized = true
      MINIONS << npc

      xm[8] = (xm[0] + xm[4]) // 2
      ym[8] = (ym[0] + ym[4]) // 2
      MINIONS << add_spawn(FAKE_BELETH, Location.new(xm[8], ym[8], -9357, 49152))
      xm[9] = (xm[4] + xm[1]) // 2
      ym[9] = (ym[4] + ym[1]) // 2
      MINIONS << add_spawn(FAKE_BELETH, Location.new(xm[9], ym[9], -9357, 49152))
      xm[10] = (xm[1] + xm[5]) // 2
      ym[10] = (ym[1] + ym[5]) // 2
      MINIONS << add_spawn(FAKE_BELETH, Location.new(xm[10], ym[10], -9357, 49152))
      xm[11] = (xm[5] + xm[2]) // 2
      ym[11] = (ym[5] + ym[2]) // 2
      MINIONS << add_spawn(FAKE_BELETH, Location.new(xm[11], ym[11], -9357, 49152))
      xm[12] = (xm[2] + xm[6]) // 2
      ym[12] = (ym[2] + ym[6]) // 2
      MINIONS << add_spawn(FAKE_BELETH, Location.new(xm[12], ym[12], -9357, 49152))
      xm[13] = (xm[6] + xm[3]) // 2
      ym[13] = (ym[6] + ym[3]) // 2
      MINIONS << add_spawn(FAKE_BELETH, Location.new(xm[13], ym[13], -9357, 49152))
      xm[14] = (xm[3] + xm[7]) // 2
      ym[14] = (ym[3] + ym[7]) // 2
      MINIONS << add_spawn(FAKE_BELETH, Location.new(xm[14], ym[14], -9357, 49152))
      xm[15] = (xm[7] + xm[0]) // 2
      ym[15] = (ym[7] + ym[0]) // 2
      MINIONS << add_spawn(FAKE_BELETH, Location.new(xm[15], ym[15], -9357, 49152))

      @allowed_l2id = MINIONS.sample(random: Rnd).l2id
    when "SPAWN_REAL"
      @beleth = add_spawn(REAL_BELETH, Location.new(16323, 213170, -9357, 49152))
    when "SPAWN26"
      @beleth.not_nil!.do_die(nil)

      @camera1 = add_spawn(29122, Location.new(16323, 213170, -9357))
      @camera1.not_nil!.broadcast_packet(Music::BS07_D_10000.packet)

      @zone.broadcast_packet(SpecialCamera.new(@camera1.not_nil!, 400, 290, 25, 0, 10000, 0, 0, 1, 0, 0))
      @zone.broadcast_packet(SpecialCamera.new(@camera1.not_nil!, 400, 290, 25, 0, 10000, 0, 0, 1, 0, 0))
      @zone.broadcast_packet(SpecialCamera.new(@camera1.not_nil!, 400, 110, 25, 4000, 10000, 0, 0, 1, 0, 0))
      @zone.broadcast_packet(SocialAction.new(@beleth.not_nil!.l2id, 5))

      start_quest_timer("SPAWN27", 4000, nil, nil)
    when "SPAWN27"
      @zone.broadcast_packet(SpecialCamera.new(@camera1.not_nil!, 400, 295, 25, 4000, 5000, 0, 0, 1, 0, 0))
      start_quest_timer("SPAWN28", 4500, nil, nil)
    when "SPAWN28"
      @zone.broadcast_packet(SpecialCamera.new(@camera1.not_nil!, 400, 295, 10, 4000, 11000, 0, 25, 1, 0, 0))
      start_quest_timer("SPAWN29", 9000, nil, nil)
    when "SPAWN29"
      @zone.broadcast_packet(SpecialCamera.new(@camera1.not_nil!, 250, 90, 25, 0, 1000, 0, 0, 1, 0, 0))
      @zone.broadcast_packet(SpecialCamera.new(@camera1.not_nil!, 250, 90, 25, 0, 10000, 0, 0, 1, 0, 0))

      start_quest_timer("SPAWN30", 2000, nil, nil)
    when "SPAWN30"
      @priest.not_nil!.spawn_me
      @beleth.not_nil!.delete_me

      @camera2 = add_spawn(29121, Location.new(14056, 213170, -9357))
      start_quest_timer("SPAWN31", 3500, nil, nil)
    when "SPAWN31"
      @zone.broadcast_packet(SpecialCamera.new(@camera2.not_nil!, 800, 180, 0, 0, 4000, 0, 10, 1, 0, 0))
      @zone.broadcast_packet(SpecialCamera.new(@camera2.not_nil!, 800, 180, 0, 0, 4000, 0, 10, 1, 0, 0))

      door2 = DoorData.get_door(DOOR2).not_nil!
      door2.open_me

      @zone.broadcast_packet(StaticObject.new(door2, false))
      @zone.broadcast_packet(DoorStatusUpdate.new(door2))

      DoorData.get_door(DOOR3).not_nil!.open_me

      @camera1.not_nil!.delete_me
      @camera2.not_nil!.delete_me
      @whirpool.not_nil!.delete_me

      @zone.characters_inside.each do |c|
        c.enable_all_skills
        c.invul = false
        c.immobilized = false
      end
    when "CHECK_ATTACK"
      if @last_attack + 900000 < Time.ms
        GrandBossManager.set_boss_status(REAL_BELETH, ALIVE)
        @zone.characters_inside.each do |c|
          if c.npc?
            c.delete_me
          elsif c.player?
            c.tele_to_location(MapRegionManager.get_tele_to_location(c, TeleportWhereType::TOWN))
          end
        end
        cancel_quest_timer("CHECK_ATTACK", nil, nil)
      else
        start_quest_timer("CHECK_ATTACK", 60000, nil, nil)
      end
    else
      # [automatically added else]
    end


    super
  end

  def on_enter_zone(char, zone)
    if char.player? && GrandBossManager.get_boss_status(REAL_BELETH) == INIT
      @priest.try &.delete_me
      @stone.try &.delete_me

      GrandBossManager.set_boss_status(REAL_BELETH, FIGHT)
      start_quest_timer("SPAWN1", 300000, nil, nil)
    end

    super
  end

  def on_skill_see(npc, pc, skill, targets, is_summon)
    if npc.alive? && npc.id == REAL_BELETH && !npc.casting_now?
      if skill.has_effect_type?(EffectType::HP) && Rnd.rand(100) < 80
        npc.target = pc
        npc.do_cast(HORN_OF_RISING)
      end
    end

    nil
  end

  def on_aggro_range_enter(npc, pc, is_summon)
    if npc.alive? && !npc.casting_now?
      if Rnd.rand(100) < 40
        unless npc.known_list.each_player(200).empty?
          npc.do_cast(BLEED)
          return
        end
      end

      npc.target = pc
      npc.do_cast(FIREBALL)
    end

    nil
  end

  def on_spell_finished(npc, pc, skill)
    if npc.alive? && !npc.casting_now?
      if pc.alive?
        distance2 = npc.calculate_distance(pc, false, false)
        if distance2 > 890 && !npc.movement_disabled?
          npc.target = pc
          npc.set_intention(AI::FOLLOW, pc)
          speed = npc.running? ? npc.run_speed : npc.walk_speed
          time = (((distance2 - 890) / speed) * 1000).to_i
          start_quest_timer("CAST", time, npc, nil)
        elsif distance2 < 890
          npc.target = pc
          npc.do_cast(FIREBALL)
        end

        return
      end
      if Rnd.rand(100) < 40
        unless npc.known_list.each_player(200).empty?
          npc.do_cast(LIGHTENING)
          return
        end
      end
      npc.known_list.each_player(950) do |plr|
        npc.target = plr
        npc.do_cast(FIREBALL)
        return
      end
      npc.as(L2Attackable).clear_aggro_list
    end

    nil
  end

  def on_spawn(npc)
    npc.set_running
    if !npc.known_list.each_player(300).empty? && Rnd.rand(100) < 60
      npc.do_cast(BLEED)
    end
    if npc.id == REAL_BELETH
      npc.spawn.respawn_delay = 0
    end

    nil
  end

  def on_talk(npc, pc)
    if (killer = @killer) && pc.l2id == killer.l2id
      @killer = nil
      give_items(pc, RING)
      html = "data/html/default/32470a.htm"
    else
      html = "data/html/default/32470b.htm"
    end

    HtmCache.get_htm(pc, html)
  end

  def on_first_talk(npc, pc)
    on_talk(npc, pc)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if Rnd.rand(100) < 40
      return
    end

    distance = npc.calculate_distance(attacker, false, false)
    if distance > 500 || Rnd.rand(100) < 80
      MINIONS.each do |beleth|
        if beleth.alive? && Util.in_range?(900, beleth, attacker, false) && !beleth.casting_now?
          beleth.target = attacker
          beleth.do_cast(FIREBALL)
        end
      end
      beleth = @beleth
      if beleth && (beleth.alive? && Util.in_range?(900, beleth, attacker, false) && !beleth.casting_now?)
        beleth.target = attacker
        beleth.do_cast(FIREBALL)
      end
    elsif npc.alive? && !npc.casting_now?
      unless npc.known_list.each_player(200).empty?
        npc.do_cast(LIGHTENING)
        return
      end
      npc.as(L2Attackable).clear_aggro_list
    end

    nil
  end

  def on_kill(npc, killer, is_summon)
    if npc.id == REAL_BELETH
      cancel_quest_timer("CHECK_ATTACK", nil, nil)

      set_beleth_killer(killer)
      GrandBossManager.set_boss_status(REAL_BELETH, DEAD)
      respawn_time = (Config.beleth_spawn_interval.to_i64 + Rnd.rand(-Config.beleth_spawn_random..Config.beleth_spawn_random)) * 3600000
      info = GrandBossManager.get_stats_set(REAL_BELETH).not_nil!
      info["respawn_time"] = Time.ms + respawn_time
      GrandBossManager.set_stats_set(REAL_BELETH, info)
      start_quest_timer("BELETH_UNLOCK", respawn_time, nil, nil)

      delete_all
      npc.delete_me

      @zone.characters_inside.each do |c|
        c.disable_all_skills
        c.invul = true
        c.immobilized = true
      end

      beleth = add_spawn(REAL_BELETH, Location.new(16323, 213170, -9357, 49152))
      beleth.disable_all_skills
      beleth.invul = true
      beleth.immobilized = true
      @beleth = beleth

      priest = add_spawn(ELF, Location.new(beleth))
      priest.show_summon_animation = true
      priest.decay_me
      @priest = priest

      @stone = add_spawn(STONE_COFFIN, Location.new(12470, 215607, -9381, 49152))

      start_quest_timer("SPAWN26", 1000, nil, nil)
    elsif npc.l2id == @allowed_l2id
      delete_all

      @killed_count &+= 1
      if @killed_count >= 5
        start_quest_timer("SPAWN_REAL", 60000, nil, nil)
      else
        start_quest_timer("SPAWN25", 60000, nil, nil)
      end
    end

    nil
  end

  private def set_beleth_killer(killer)
    if party = killer.party
      if cc = party.command_channel
        @killer = cc.leader
      else
        @killer = party.leader
      end
    else
      @killer = killer
    end
  end

  private def delete_all
    MINIONS.each do |n|
      next if n.dead?
      n.abort_cast
      n.target = nil
      n.intention = AI::IDLE
      n.delete_me
    end

    @allowed_l2id = 0
  end
end
