class Scripts::Antharas < AbstractNpcAI
  # NPC
  private ANTHARAS = 29068 # Antharas
  private BEHEMOTH = 29069 # Behemoth Dragon
  private TERASQUE = 29190 # Tarask Dragon
  private BOMBER = 29070 # Dragon Bomber
  private HEART = 13001 # Heart of Warding
  private CUBE = 31859 # Teleportation Cubic
  private INVISIBLE_NPC = {
    29077 => Location.new(177229, 113298, -7735), # antaras_clear_npc_1
    29078 => Location.new(176707, 113585, -7735), # antaras_clear_npc_2
    29079 => Location.new(176385, 113889, -7735), # antaras_clear_npc_3
    29080 => Location.new(176082, 114241, -7735), # antaras_clear_npc_4
    29081 => Location.new(176066, 114802, -7735), # antaras_clear_npc_5
    29082 => Location.new(176095, 115313, -7735), # antaras_clear_npc_6
    29083 => Location.new(176425, 115829, -7735), # antaras_clear_npc_7
    29084 => Location.new(176949, 116378, -7735), # antaras_clear_npc_8
    29085 => Location.new(177655, 116402, -7735), # antaras_clear_npc_9
    29086 => Location.new(178248, 116395, -7735), # antaras_clear_npc_10
    29087 => Location.new(178706, 115998, -7735), # antaras_clear_npc_11
    29088 => Location.new(179208, 115452, -7735), # antaras_clear_npc_12
    29089 => Location.new(179191, 115079, -7735), # antaras_clear_npc_13
    29090 => Location.new(179221, 114546, -7735), # antaras_clear_npc_14
    29091 => Location.new(178916, 113925, -7735), # antaras_clear_npc_15
    29092 => Location.new(178782, 113814, -7735), # antaras_clear_npc_16
    29093 => Location.new(178419, 113417, -7735), # antaras_clear_npc_17
    29094 => Location.new(177855, 113282, -7735)  # antaras_clear_npc_18
  }

  # Item
  private STONE = 3865 # Portal Stone
  # Skill
  private ANTH_JUMP = SkillHolder.new(4106) # Antharas Stun
  private ANTH_TAIL = SkillHolder.new(4107) # Antharas Stun
  private ANTH_FEAR = SkillHolder.new(4108) # Antharas Terror
  private ANTH_DEBUFF = SkillHolder.new(4109) # Curse of Antharas
  private ANTH_MOUTH = SkillHolder.new(4110, 2) # Breath Attack
  private ANTH_BREATH = SkillHolder.new(4111) # Antharas Fossilization
  private ANTH_NORM_ATTACK = SkillHolder.new(4112) # Ordinary Attack
  private ANTH_NORM_ATTACK_EX = SkillHolder.new(4113) # Animal doing ordinary attack
  private ANTH_REGEN_1 = SkillHolder.new(4125) # Antharas Regeneration
  private ANTH_REGEN_2 = SkillHolder.new(4239) # Antharas Regeneration
  private ANTH_REGEN_3 = SkillHolder.new(4240) # Antharas Regeneration
  private ANTH_REGEN_4 = SkillHolder.new(4241) # Antharas Regeneration
  private DISPEL_BOMB = SkillHolder.new(5042) # NPC Dispel Bomb
  private ANTH_ANTI_STRIDER = SkillHolder.new(4258) # Hinder Strider
  private ANTH_FEAR_SHORT = SkillHolder.new(5092) # Antharas Terror
  private ANTH_METEOR = SkillHolder.new(5093) # Antharas Meteor
  # Status
  private ALIVE = 0
  private WAITING = 1
  private IN_FIGHT = 2
  private DEAD = 3
  # Misc
  private MAX_PEOPLE = 200 # Max allowed players

  @antharas : L2GrandBossInstance?
  @last_attack = 0i64
  @minion_count = 0
  @minion_multiplier = 0
  @move_chance = 0
  @sandstorm = 0
  @attacker_1 : L2PcInstance?
  @attacker_2 : L2PcInstance?
  @attacker_3 : L2PcInstance?
  @attacker_1_hate = 0
  @attacker_2_hate = 0
  @attacker_3_hate = 0
  @zone : L2NoRestartZone # Antharas Nest

  def initialize
    super(self.class.simple_name, "ai/individual")

    @zone = ZoneManager.get_zone_by_id(70050, L2NoRestartZone).not_nil!

    add_start_npc(HEART, CUBE)
    add_talk_id(HEART, CUBE)
    add_first_talk_id(HEART)
    add_spawn_id(INVISIBLE_NPC.keys)
    add_spawn_id(ANTHARAS)
    add_move_finished_id(BOMBER)
    add_aggro_range_enter_id(BOMBER)
    add_spell_finished_id(ANTHARAS)
    add_attack_id(ANTHARAS, BOMBER, BEHEMOTH, TERASQUE)
    add_kill_id(ANTHARAS, TERASQUE, BEHEMOTH)

    info = GrandBossManager.get_stats_set(ANTHARAS).not_nil!
    curr_hp = info.get_f64("currentHP")
    curr_mp = info.get_f64("currentMP")
    loc_x = info.get_i32("loc_x")
    loc_y = info.get_i32("loc_y")
    loc_z = info.get_i32("loc_z")
    heading = info.get_i32("heading")
    respawn_time = info.get_i64("respawn_time")

    case get_status
    when ALIVE
      @antharas = add_spawn(ANTHARAS, 185708, 114298, -8221, 0, false, 0).as(L2GrandBossInstance)
      @antharas.not_nil!.set_current_hp_mp(curr_hp, curr_mp)
      add_boss(@antharas)
    when WAITING
      @antharas = add_spawn(ANTHARAS, 185708, 114298, -8221, 0, false, 0).as(L2GrandBossInstance)
      @antharas.not_nil!.set_current_hp_mp(curr_hp, curr_mp)
      add_boss(@antharas)
      start_quest_timer("SPAWN_ANTHARAS", Config.antharas_wait_time * 60_000, nil, nil)
    when IN_FIGHT
      @antharas = add_spawn(ANTHARAS, loc_x, loc_y, loc_z, heading, false, 0).as(L2GrandBossInstance)
      @antharas.not_nil!.set_current_hp_mp(curr_hp, curr_mp)
      add_boss(@antharas)
      @last_attack = Time.ms
      start_quest_timer("CHECK_ATTACK", 60_000, @antharas, nil)
      start_quest_timer("SPAWN_MINION", 300_000, @antharas, nil)
    when DEAD
      remain = respawn_time &- Time.ms
      if remain > 0
        start_quest_timer("CLEAR_STATUS", remain, nil, nil)
      else
        set_status(ALIVE)
        antharas = add_spawn(ANTHARAS, 185708, 114298, -8221, 0, false, 0).as(L2GrandBossInstance)
        @antharas = antharas
        add_boss(@antharas)
      end
    end
  end

  def on_adv_event(event, npc, player)
    case event
    when "enter"
      html = nil
      if get_status == DEAD
        html = "13001-01.html"
      elsif get_status == IN_FIGHT
        html = "13001-02.html"
      elsif @zone.players_inside.size >= MAX_PEOPLE
        html = "13001-04.html"
      elsif party = player.try &.party
        player = player.not_nil!
        cc = party.command_channel
        members = cc ? cc.members : party.members
        is_party_leader = cc ? cc.leader?(player) : party.leader?(player)
        if !is_party_leader
          html = "13001-05.html"
        elsif !has_quest_items?(player, STONE)
          html = "13001-03.html"
        elsif members.size > MAX_PEOPLE - @zone.players_inside.size
          html = "13001-04.html"
        else
          npc = npc.not_nil!
          members.each do |member|
            if member.inside_radius?(npc, 1000, true, false)
              member.tele_to_location(179700 &+ Rnd.rand(700), 113800 &+ Rnd.rand(2100), -7709)
            end
          end
          if get_status != WAITING
            set_status(WAITING)
            start_quest_timer("SPAWN_ANTHARAS", Config.antharas_wait_time * 60_000, nil, nil)
          end
        end
      else
        player = player.not_nil!
        if !has_quest_items?(player, STONE)
          html = "13001-03.html"
        else
          player.tele_to_location(179700 &+ Rnd.rand(700), 113800 &+ Rnd.rand(2100), -7709)
          if get_status != WAITING
            set_status(WAITING)
            start_quest_timer("SPAWN_ANTHARAS", Config.antharas_wait_time &* 60_000, nil, nil)
          end
        end
      end
      return html
    when "teleportOut"
      player = player.not_nil!
      player.tele_to_location(79800 &+ Rnd.rand(600), 151200 &+ Rnd.rand(1100), -3534)
    when "SPAWN_ANTHARAS"
      @antharas.not_nil!.tele_to_location(181323, 114850, -7623, 32542)
      set_status(IN_FIGHT)
      @last_attack = Time.ms
      @zone.broadcast_packet(Music::BS02_A_10000.packet)
      start_quest_timer("CAMERA_1", 23, @antharas, nil)
    when "CAMERA_1"
      npc = npc.not_nil!
      @zone.broadcast_packet(SpecialCamera.new(npc, 700, 13, -19, 0, 10_000, 20_000, 0, 0, 0, 0, 0))
      start_quest_timer("CAMERA_2", 3000, npc, nil)
    when "CAMERA_2"
      npc = npc.not_nil!
      @zone.broadcast_packet(SpecialCamera.new(npc, 700, 13, 0, 6000, 10_000, 20_000, 0, 0, 0, 0, 0))
      start_quest_timer("CAMERA_3", 10_000, npc, nil)
    when "CAMERA_3"
      npc = npc.not_nil!
      @zone.broadcast_packet(SpecialCamera.new(npc, 3700, 0, -3, 0, 10_000, 10_000, 0, 0, 0, 0, 0))
      @zone.broadcast_packet(SocialAction.new(npc.l2id, 1))
      start_quest_timer("CAMERA_4", 200, npc, nil)
      start_quest_timer("SOCIAL", 5200, npc, nil)
    when "CAMERA_4"
      npc = npc.not_nil!
      @zone.broadcast_packet(SpecialCamera.new(npc, 1100, 0, -3, 22000, 10_000, 30000, 0, 0, 0, 0, 0))
      start_quest_timer("CAMERA_5", 10_800, npc, nil)
    when "CAMERA_5"
      npc = npc.not_nil!
      @zone.broadcast_packet(SpecialCamera.new(npc, 1100, 0, -3, 300, 10_000, 7000, 0, 0, 0, 0, 0))
      start_quest_timer("START_MOVE", 1900, npc, nil)
    when "SOCIAL"
      npc = npc.not_nil!
      @zone.broadcast_packet(SocialAction.new(npc.l2id, 2))
    when "START_MOVE"
      npc = npc.not_nil!
      npc.known_list.get_known_players_in_radius(4000) do |plr|
        if plr.hero?
          @zone.broadcast_packet(ExShowScreenMessage.new(NpcString::S1_YOU_CANNOT_HOPE_TO_DEFEAT_ME_WITH_YOUR_MEAGER_STRENGTH, 2, 4000, plr.name))
          break
        end
      end
      npc.set_intention(AI::MOVE_TO, Location.new(179011, 114871, -7704))
      start_quest_timer("CHECK_ATTACK", 60_000, npc, nil)
      start_quest_timer("SPAWN_MINION", 300_000, npc, nil)
    when "SET_REGEN"
      if npc
        if npc.hp_percent < 25
          unless npc.affected_by_skill?(ANTH_REGEN_4.skill_id)
            npc.do_cast(ANTH_REGEN_4)
          end
        elsif npc.hp_percent < 50
          unless npc.affected_by_skill?(ANTH_REGEN_3.skill_id)
            npc.do_cast(ANTH_REGEN_3)
          end
        elsif npc.hp_percent < 75
          unless npc.affected_by_skill?(ANTH_REGEN_2.skill_id)
            npc.do_cast(ANTH_REGEN_2)
          end
        elsif !npc.affected_by_skill?(ANTH_REGEN_1.skill_id)
          npc.do_cast(ANTH_REGEN_1)
        end
        start_quest_timer("SET_REGEN", 60_000, npc, nil)
      end
    when "CHECK_ATTACK"
      if npc && @last_attack &+ 900_000 < Time.ms
        set_status(ALIVE)
        @zone.each_character_inside do |char|
          if char.npc?
            if char.id == ANTHARAS
              char.tele_to_location(185708, 114298, -8221)
            else
              char.delete_me
            end
          elsif char.player?
            char.tele_to_location(79800 &+ Rnd.rand(600), 151200 &+ Rnd.rand(1100), -3534)
          end
        end
        cancel_quest_timer("CHECK_ATTACK", npc, nil)
        cancel_quest_timer("SPAWN_MINION", npc, nil)
      elsif npc
        if @attacker_1_hate > 10
          @attacker_1_hate &-= Rnd.rand(10)
        end
        if @attacker_2_hate > 10
          @attacker_2_hate &-= Rnd.rand(10)
        end
        if @attacker_3_hate > 10
          @attacker_3_hate &-= Rnd.rand(10)
        end
        manage_skills(npc)
        start_quest_timer("CHECK_ATTACK", 60_000, npc, nil)
      end
    when "SPAWN_MINION"
      npc = npc.not_nil!
      if @minion_multiplier > 1 && @minion_count < 100 &- (@minion_multiplier &* 2)
        @minion_multiplier.times do
          add_spawn(BEHEMOTH, npc, true)
          add_spawn(TERASQUE, npc, true)
        end
        @minion_count &+= @minion_multiplier &* 2
      elsif @minion_count < 98
        add_spawn(BEHEMOTH, npc, true)
        add_spawn(TERASQUE, npc, true)
        @minion_count &+= 2
      elsif @minion_count < 99
        add_spawn(Rnd.bool ? BEHEMOTH : TERASQUE, npc, true)
        @minion_count &+= 1
      end

      if Rnd.rand(100) > 10 && @minion_multiplier < 4
        @minion_multiplier += 1
      end
      start_quest_timer("SPAWN_MINION", 300_000, npc, nil)
    when "CLEAR_ZONE"
      @zone.each_character_inside do |char|
        if char.npc?
          char.delete_me
        elsif char.player?
          char.tele_to_location(79800 &+ Rnd.rand(600), 151200 &+ Rnd.rand(1100), -3534)
        end
      end
    when "TID_USED_FEAR"
      if npc && @sandstorm == 0
        @sandstorm = 1
        npc.disable_core_ai(true)
        npc.set_intention(AI::MOVE_TO, Location.new(177648, 114816, -7735))
        start_quest_timer("TID_FEAR_MOVE_TIMEOVER", 2000, npc, nil)
        start_quest_timer("TID_FEAR_COOLTIME", 300_000, npc, nil)
      end
    when "TID_FEAR_COOLTIME"
      @sandstorm = 0
    when "TID_FEAR_MOVE_TIMEOVER"
      npc = npc.not_nil!
      if @sandstorm == 1 && npc.x == 177648 && npc.y == 114816
        @sandstorm = 2
        @move_chance = 0
        npc.disable_core_ai(false)
        INVISIBLE_NPC.each { |k, v| add_spawn(k, v) }
      elsif @sandstorm == 1
        if @move_chance <= 3
          @move_chance &+= 1
          npc.set_intention(AI::MOVE_TO, Location.new(177648, 114816, -7735))
          start_quest_timer("TID_FEAR_MOVE_TIMEOVER", 5000, npc, nil)
        else
          npc.tele_to_location(177648, 114816, -7735, npc.heading)
          start_quest_timer("TID_FEAR_MOVE_TIMEOVER", 1000, npc, nil)
        end
      end
    when "CLEAR_STATUS"
      @antharas = add_spawn(ANTHARAS, 185708, 114298, -8221, 0, false, 0).as(L2GrandBossInstance)
      add_boss(@antharas.not_nil!)
      Broadcast.to_all_online_players(Earthquake.new(185708, 114298, -8221, 20, 10))
      set_status(ALIVE)
    when "SKIP_WAITING"
      player = player.not_nil!
      if get_status == WAITING
        cancel_quest_timer("SPAWN_ANTHARAS", nil, nil)
        notify_event("SPAWN_ANTHARAS", nil, nil)
        player.send_message("#{self.class.simple_name}: Skipping waiting time ...")
      else
        player.send_message("#{self.class.simple_name}: You can't skip waiting time right now.")
      end
    when "RESPAWN_ANTHARAS"
      player = player.not_nil!
      if get_status == DEAD
        set_respawn(0)
        cancel_quest_timer("CLEAR_STATUS", nil, nil)
        notify_event("CLEAR_STATUS", nil, nil)
        player.send_message("#{self.class.simple_name}: Antharas has been respawned.")
      else
        player.send_message("#{self.class.simple_name}: You can't respawn antharas while antharas is alive.")
      end
    when "DESPAWN_MINIONS"
      if get_status == IN_FIGHT
        @minion_count = 0
        @zone.each_character_inside do |char|
          if char.npc? && char.id.in?(BEHEMOTH, TERASQUE)
            char.delete_me
          end
        end
        if player # Player dont will be nil just when is this event called from GM command
          player.send_message("#{self.class.simple_name}: All minions have been deleted.")
        end
      elsif player # Player dont will be nil just when is this event called from GM command
        player.send_message("#{self.class.simple_name}: You can't despawn minions right now.")
      end
    when "ABORT_FIGHT"
      player = player.not_nil!
      if get_status == IN_FIGHT
        set_status(ALIVE)
        cancel_quest_timer("CHECK_ATTACK", @antharas, nil)
        cancel_quest_timer("SPAWN_MINION", @antharas, nil)
        @zone.each_character_inside do |char|
          if char.npc?
            if char.id == ANTHARAS
              char.tele_to_location(185708, 114298, -8221)
            else
              char.delete_me
            end
          elsif char.player? && !char.gm?
            char.tele_to_location(79800 &+ Rnd.rand(600), 151200 &+ Rnd.rand(1100), -3534)
          end
        end
        player.send_message("#{self.class.simple_name}: Fight has been aborted.")
      else
        player.send_message("#{self.class.simple_name}: You can't abort fight right now.")
      end
    when "MANAGE_SKILL"
      manage_skills(npc)
    end

    super
  end

  def on_aggro_range_enter(npc, player, is_summon)
    npc.do_cast(DISPEL_BOMB)
    npc.do_die(player)

    super
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    @last_attack = Time.ms

    if npc.id == BOMBER
      if npc.calculate_distance(attacker, true, false) < 230
        npc.do_cast(DISPEL_BOMB)
        npc.do_die(attacker)
      end
    elsif npc.id == ANTHARAS
      if !@zone.character_in_zone?(attacker) || get_status != IN_FIGHT
        warn { "Player #{attacker.name} attacked Antharas in invalid conditions." }
        attacker.tele_to_location(80464, 152294, -3534)
      end

      if attacker.mount_type.strider? && !attacker.affected_by_skill?(ANTH_ANTI_STRIDER.skill_id)
        if npc.check_do_cast_conditions(ANTH_ANTI_STRIDER.skill)
          npc.target = attacker
          npc.do_cast(ANTH_ANTI_STRIDER)
        end
      end

      if skill.nil?
        refresh_ai_params(attacker, damage &* 1000)
      elsif npc.hp_percent < 25
        refresh_ai_params(attacker, (damage // 3) &* 100)
      elsif npc.hp_percent < 50
        refresh_ai_params(attacker, damage &* 20)
      elsif npc.hp_percent < 75
        refresh_ai_params(attacker, damage &* 10)
      else
        refresh_ai_params(attacker, (damage // 3) &* 20)
      end
      manage_skills(npc)
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if @zone.character_in_zone?(killer)
      if npc.id == ANTHARAS
        @antharas = nil
        notify_event("DESPAWN_MINIONS", nil, nil)
        @zone.broadcast_packet(SpecialCamera.new(npc, 1200, 20, -10, 0, 10_000, 13_000, 0, 0, 0, 0, 0))
        @zone.broadcast_packet(Music::BS01_D_10000.packet)
        add_spawn(CUBE, 177615, 114941, -7709, 0, false, 900_000)
        respawn_time = (Config.antharas_spawn_interval &+ Rnd.rand(-Config.antharas_spawn_random..Config.antharas_spawn_random)) &* 3_600_000
        set_respawn(respawn_time)
        start_quest_timer("CLEAR_STATUS", respawn_time, nil, nil)
        cancel_quest_timer("SET_REGEN", npc, nil)
        cancel_quest_timer("CHECK_ATTACK", npc, nil)
        cancel_quest_timer("SPAWN_MINION", npc, nil)
        start_quest_timer("CLEAR_ZONE", 900_000, nil, nil)
        set_status(DEAD)
      else
        @minion_count &-= 1
      end
    end

    super
  end

  def on_move_finished(npc)
    npc.do_cast(DISPEL_BOMB)
    npc.do_die(nil)
  end

  def on_spawn(npc)
    if npc.id == ANTHARAS
      cancel_quest_timer("SET_REGEN", npc, nil)
      start_quest_timer("SET_REGEN", 60_000, npc, nil)
      npc.as(L2Attackable).on_kill_delay = 0
    else
      1.upto(6) do |i|
        x = npc.template.parameters.get_i32("suicide#{i}_x")
        y = npc.template.parameters.get_i32("suicide#{i}_y")
        bomber = add_spawn(BOMBER, *npc.xyz, 0, true, 15_000, true)
        bomber.set_intention(AI::MOVE_TO, Location.new(x, y, npc.z))
      end
      npc.delete_me
    end

    super
  end

  def on_spell_finished(npc, player, skill)
    if skill.id == ANTH_FEAR.skill_id || skill.id == ANTH_FEAR_SHORT.skill_id
      start_quest_timer("TID_USED_FEAR", 7000, npc, nil)
    end
    start_quest_timer("MANAGE_SKILL", 1000, npc, nil)

    super
  end

  def unload(remove_from_list : Bool)
    if a = @antharas
      a.delete_me
      @antharas = nil
    end

    super
  end

  private def get_status
    GrandBossManager.get_boss_status(ANTHARAS)
  end

  private def add_boss(grandboss)
    GrandBossManager.add_boss(grandboss)
  end

  private def set_status(status)
    GrandBossManager.set_boss_status(ANTHARAS, status)
  end

  private def set_respawn(respawn_time)
    stats_set = GrandBossManager.get_stats_set(ANTHARAS).not_nil!
    stats_set["respawn_time"] = Time.ms &+ respawn_time
  end

  private def refresh_ai_params(attacker, damage)
    if @attacker_1 && attacker == @attacker_1
      if @attacker_1_hate < damage &+ 1000
        @attacker_1_hate = damage &+ Rnd.rand(3000)
      end
    elsif @attacker_2 && attacker == @attacker_2
      if @attacker_2_hate < damage &+ 1000
        @attacker_2_hate = damage &+ Rnd.rand(3000)
      end
    elsif @attacker_3 && attacker == @attacker_3
      if @attacker_3_hate < damage &+ 1000
        @attacker_3_hate = damage &+ Rnd.rand(3000)
      end
    else
      i1 = Util.min(@attacker_1_hate, @attacker_2_hate, @attacker_3_hate)
      if @attacker_1_hate == i1
        @attacker_1_hate = damage &+ Rnd.rand(3000)
        @attacker_1 = attacker
      elsif @attacker_2_hate == i1
        @attacker_2_hate = damage &+ Rnd.rand(3000)
        @attacker_2 = attacker
      elsif @attacker_3_hate == i1
        @attacker_3_hate = damage &+ Rnd.rand(3000)
        @attacker_3 = attacker
      end
    end
  end

  private def manage_skills(npc)
    npc = npc.not_nil!
    if npc.casting_now? || npc.core_ai_disabled? || !npc.in_combat?
      return
    end

    i1 = 0
    i2 = 0

    if @attacker_1.nil? || npc.calculate_distance(@attacker_1.not_nil!, true, false) > 9000 || @attacker_1.not_nil!.dead?
      @attacker_1_hate = 0
    end

    if @attacker_2.nil? || npc.calculate_distance(@attacker_2.not_nil!, true, false) > 9000 || @attacker_2.not_nil!.dead?
      @attacker_2_hate = 0
    end

    if @attacker_3.nil? || npc.calculate_distance(@attacker_3.not_nil!, true, false) > 9000 || @attacker_3.not_nil!.dead?
      @attacker_3_hate = 0
    end

    if @attacker_1_hate > @attacker_2_hate
      i1 = 2
      i2 = @attacker_1_hate
      c2 = @attacker_1
    elsif @attacker_2_hate > 0
      i1 = 3
      i2 = @attacker_2_hate
      c2 = @attacker_2
    end

    if @attacker_3_hate > i2
      i1 = 4
      i2 = @attacker_3_hate
      c2 = @attacker_3
    end
    if i2 > 0
      if Rnd.rand(100) < 70
        case i1
        when 2
          @attacker_1_hate = 500
        when 3
          @attacker_2_hate = 500
        when 4
          @attacker_3_hate = 500
        end
      end

      distance_c2 = npc.calculate_distance(c2.not_nil!, true, false)
      direction_c2 = npc.calculate_direction_to(c2.not_nil!)

      if npc.hp_percent < 25
        if Rnd.rand(100) < 30
          npc.target = c2
          skill_to_cast = ANTH_MOUTH
        elsif Rnd.rand(100) < 80 && ((distance_c2 < 1423 && direction_c2 < 188 && direction_c2 > 172) || (distance_c2 < 802 && direction_c2 < 194 && direction_c2 > 166))
          skill_to_cast = ANTH_TAIL
        elsif Rnd.rand(100) < 40 && ((distance_c2 < 850 && direction_c2 < 210 && direction_c2 > 150) || (distance_c2 < 425 && direction_c2 < 270 && direction_c2 > 90))
          skill_to_cast = ANTH_DEBUFF
        elsif Rnd.rand(100) < 10 && distance_c2 < 1100
          skill_to_cast = ANTH_JUMP
        elsif Rnd.rand(100) < 10
          npc.target = c2
          skill_to_cast = ANTH_METEOR
        elsif Rnd.rand(100) < 6
          npc.target = c2
          skill_to_cast = ANTH_BREATH
        elsif Rnd.bool
          npc.target = c2
          skill_to_cast = ANTH_NORM_ATTACK_EX
        elsif Rnd.rand(100) < 5
          npc.target = c2
          skill_to_cast = Rnd.bool ? ANTH_FEAR : ANTH_FEAR_SHORT
        else
          npc.target = c2
          skill_to_cast = ANTH_NORM_ATTACK
        end
      elsif npc.hp_percent < 50
        if Rnd.rand(100) < 80 && ((distance_c2 < 1423 && direction_c2 < 188 && direction_c2 > 172) || (distance_c2 < 802 && direction_c2 < 194 && direction_c2 > 166))
          skill_to_cast = ANTH_TAIL
        elsif Rnd.rand(100) < 40 && ((distance_c2 < 850 && direction_c2 < 210 && direction_c2 > 150) || (distance_c2 < 425 && direction_c2 < 270 && direction_c2 > 90))
          skill_to_cast = ANTH_DEBUFF
        elsif Rnd.rand(100) < 10 && distance_c2 < 1100
          skill_to_cast = ANTH_JUMP
        elsif Rnd.rand(100) < 7
          npc.target = c2
          skill_to_cast = ANTH_METEOR
        elsif Rnd.rand(100) < 6
          npc.target = c2
          skill_to_cast = ANTH_BREATH
        elsif Rnd.bool
          npc.target = c2
          skill_to_cast = ANTH_NORM_ATTACK_EX
        elsif Rnd.rand(100) < 5
          npc.target = c2
          skill_to_cast = Rnd.bool ? ANTH_FEAR : ANTH_FEAR_SHORT
        else
          npc.target = c2
          skill_to_cast = ANTH_NORM_ATTACK
        end
      elsif npc.hp_percent < 75
        if Rnd.rand(100) < 80 && ((distance_c2 < 1423 && direction_c2 < 188 && direction_c2 > 172) || (distance_c2 < 802 && direction_c2 < 194 && direction_c2 > 166))
          skill_to_cast = ANTH_TAIL
        elsif Rnd.rand(100) < 10 && distance_c2 < 1100
          skill_to_cast = ANTH_JUMP
        elsif Rnd.rand(100) < 5
          npc.target = c2
          skill_to_cast = ANTH_METEOR
        elsif Rnd.rand(100) < 6
          npc.target = c2
          skill_to_cast = ANTH_BREATH
        elsif Rnd.bool
          npc.target = c2
          skill_to_cast = ANTH_NORM_ATTACK_EX
        elsif Rnd.rand(100) < 5
          npc.target = c2
          skill_to_cast = Rnd.bool ? ANTH_FEAR : ANTH_FEAR_SHORT
        else
          npc.target = c2
          skill_to_cast = ANTH_NORM_ATTACK
        end
      elsif Rnd.rand(100) < 80 && ((distance_c2 < 1423 && direction_c2 < 188 && direction_c2 > 172) || (distance_c2 < 802 && direction_c2 < 194 && direction_c2 > 166))
        skill_to_cast = ANTH_TAIL
      elsif Rnd.rand(100) < 3
        npc.target = c2
        skill_to_cast = ANTH_METEOR
      elsif Rnd.rand(100) < 6
        npc.target = c2
        skill_to_cast = ANTH_BREATH
      elsif Rnd.bool
        npc.target = c2
        skill_to_cast = ANTH_NORM_ATTACK_EX
      elsif Rnd.rand(100) < 5
        npc.target = c2
        skill_to_cast = Rnd.bool ? ANTH_FEAR : ANTH_FEAR_SHORT
      else
        npc.target = c2
        skill_to_cast = ANTH_NORM_ATTACK
      end

      if skill_to_cast && npc.check_do_cast_conditions(skill_to_cast.skill)
        npc.do_cast(skill_to_cast)
      end
    end
  end
end
