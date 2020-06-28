class Scripts::Baium < AbstractNpcAI
  # NPCs
  private BAIUM = 29020 # Baium
  private BAIUM_STONE = 29025 # Baium
  private ANG_VORTEX = 31862 # Angelic Vortex
  private ARCHANGEL = 29021 # Archangel
  private TELE_CUBE = 31842 # Teleportation Cubic
  # Skills
  private BAIUM_ATTACK = SkillHolder.new(4127) # Baium: General Attack
  private ENERGY_WAVE = SkillHolder.new(4128) # Wind Of Force
  private EARTH_QUAKE = SkillHolder.new(4129) # Earthquake
  private THUNDERBOLT = SkillHolder.new(4130) # Striking of Thunderbolt
  private GROUP_HOLD = SkillHolder.new(4131) # Stun
  private SPEAR_ATTACK = SkillHolder.new(4132) # Spear: Pound the Ground
  private ANGEL_HEAL = SkillHolder.new(4133) # Angel Heal
  private HEAL_OF_BAIUM = SkillHolder.new(4135) # Baium Heal
  private BAIUM_PRESENT = SkillHolder.new(4136) # Baium's Gift
  private ANTI_STRIDER = SkillHolder.new(4258) # Hinder Strider
  # Items
  private FABRIC = 4295 # Blooded Fabric
  # Status
  private ALIVE = 0
  private WAITING = 1
  private IN_FIGHT = 2
  private DEAD = 3
  # Locations
  private BAIUM_GIFT_LOC = Location.new(115910, 17337, 10105)
  private BAIUM_LOC = Location.new(116033, 17447, 10107, -25348)
  private TELEPORT_CUBIC_LOC = Location.new(115017, 15549, 10090)
  private TELEPORT_IN_LOC = Location.new(114077, 15882, 10078)
  private TELEPORT_OUT_LOC = {
    Location.new(108784, 16000, -4928),
    Location.new(113824, 10448, -5164),
    Location.new(115488, 22096, -5168),
  }
  private ARCHANGEL_LOC = {
    Location.new(115792, 16608, 10136, 0),
    Location.new(115168, 17200, 10136, 0),
    Location.new(115780, 15564, 10136, 13620),
    Location.new(114880, 16236, 10136, 5400),
    Location.new(114239, 17168, 10136, -1992)
  }
  # Misc
  @baium : L2GrandBossInstance?
  @last_attack = 0i64
  @zone : L2NoRestartZone

  def initialize
    super(self.class.simple_name, "ai/individual")

    @zone = ZoneManager.get_zone_by_id(70051, L2NoRestartZone).not_nil!

    add_first_talk_id(ANG_VORTEX)
    add_talk_id(ANG_VORTEX, TELE_CUBE, BAIUM_STONE)
    add_start_npc(ANG_VORTEX, TELE_CUBE, BAIUM_STONE)
    add_attack_id(BAIUM, ARCHANGEL)
    add_kill_id(BAIUM)
    add_see_creature_id(BAIUM)
    add_spell_finished_id(BAIUM)

    info = GrandBossManager.get_stats_set(BAIUM).not_nil!
    curr_hp = info.get_f64("currentHP")
    curr_mp = info.get_f64("currentMP")
    loc_x = info.get_i32("loc_x")
    loc_y = info.get_i32("loc_y")
    loc_z = info.get_i32("loc_z")
    heading = info.get_i32("heading")
    respawn_time = info.get_i64("respawn_time")

    case get_status
    when WAITING
      set_status(ALIVE)
    when ALIVE
      add_spawn(BAIUM_STONE, BAIUM_LOC, false, 0)
    when IN_FIGHT
      @baium = add_spawn(BAIUM, loc_x, loc_y, loc_z, heading, false, 0).as(L2GrandBossInstance)
      @baium.not_nil!.set_current_hp_mp(curr_hp, curr_mp)
      @last_attack = Time.ms
      add_boss(@baium.not_nil!)

      ARCHANGEL_LOC.each do |loc|
        archangel = add_spawn(ARCHANGEL, loc, false, 0, true)
        start_quest_timer("SELECT_TARGET", 5000, archangel, nil)
      end
      start_quest_timer("CHECK_ATTACK", 60000, @baium, nil)
    when DEAD
      remain = respawn_time - Time.ms
      if remain > 0
        start_quest_timer("CLEAR_STATUS", remain, nil, nil)
      else
        notify_event("CLEAR_STATUS", nil, nil)
      end
    end

  end

  def on_adv_event(event, npc, player)
    case event
    when "31862-04.html"
      return event
    when "enter"
      player = player.not_nil!
      if get_status == DEAD
        html = "31862-03.html"
      elsif get_status == IN_FIGHT
        html = "31862-02.html"
      elsif !has_quest_items?(player, FABRIC) # player.not_nil! has no type??
        html = "31862-01.html"
      else
        take_items(player, FABRIC, 1)
        player.tele_to_location(TELEPORT_IN_LOC)
      end
      return html
    when "teleportOut"
      loc = TELEPORT_OUT_LOC.sample(random: Rnd)
      player.not_nil!.tele_to_location(loc.x + Rnd.rand(100), loc.y + Rnd.rand(100), loc.z)
    when "wakeUp"
      if get_status == ALIVE
        npc.not_nil!.delete_me
        set_status(IN_FIGHT)
        @baium = add_spawn(BAIUM, BAIUM_LOC, false, 0).as(L2GrandBossInstance)
        @baium.not_nil!.disable_core_ai(true)
        add_boss(@baium)
        @last_attack = Time.ms
        start_quest_timer("WAKEUP_ACTION", 50, @baium, nil)
        start_quest_timer("MANAGE_EARTHQUAKE", 2000, @baium, nil)
        start_quest_timer("SOCIAL_ACTION", 10000, @baium, player)
        start_quest_timer("CHECK_ATTACK", 60000, @baium, nil)
      end
    when "WAKEUP_ACTION"
      if npc
        @zone.broadcast_packet(SocialAction.new(@baium.not_nil!.l2id, 2))
      end
    when "MANAGE_EARTHQUAKE"
      if npc
        @zone.broadcast_packet(Earthquake.new(*npc.xyz, 40, 10))
        @zone.broadcast_packet(Music::BS02_A_6000.packet)
      end
    when "SOCIAL_ACTION"
      if npc
        @zone.broadcast_packet(SocialAction.new(npc.l2id, 3))
        start_quest_timer("PLAYER_PORT", 6000, npc, player)
      end
    when "PLAYER_PORT"
      if npc
        if player && player.inside_radius?(npc, 16000, true, false)
          player.tele_to_location(BAIUM_GIFT_LOC)
          start_quest_timer("PLAYER_KILL", 3000, npc, player)
        else
          if random_pc = get_random_player(npc)
            random_pc.tele_to_location(BAIUM_GIFT_LOC)
            start_quest_timer("PLAYER_KILL", 3000, npc, random_pc)
          else
            start_quest_timer("PLAYER_KILL", 3000, npc, nil)
          end
        end
      end
    when "PLAYER_KILL"
      npc = npc.not_nil!
      if player && player.inside_radius?(npc, 16000, true, false)
        @zone.broadcast_packet(SocialAction.new(npc.l2id, 1))
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::HOW_DARE_YOU_WAKE_ME_NOW_YOU_SHALL_DIE, player.name)
        npc.target = player
        npc.do_cast(BAIUM_PRESENT)
      end

      @zone.players_inside.each do |plr|
        if plr.hero?
          npc_str = NpcString::NOT_EVEN_THE_GODS_THEMSELVES_COULD_TOUCH_ME_BUT_YOU_S1_YOU_DARE_CHALLENGE_ME_IGNORANT_MORTAL
          msg = ExShowScreenMessage.new(npc_str, 2, 4000, plr.name)
          @zone.broadcast_packet(msg)
          break
        end
      end
      start_quest_timer("SPAWN_ARCHANGEL", 8000, npc, player)
    when "SPAWN_ARCHANGEL"
      @baium.not_nil!.disable_core_ai(false)

      ARCHANGEL_LOC.each do |loc|
        archangel = add_spawn(ARCHANGEL, loc, false, 0, true)
        start_quest_timer("SELECT_TARGET", 5000, archangel, nil)
      end
      npc = npc.not_nil!
      if player && player.alive?
        add_attack_desire(npc, player)
      else
        if random_pc = get_random_player(npc)
          add_attack_desire(npc, random_pc)
        end
      end
    when "SELECT_TARGET"
      if npc
        mob = npc.as(L2Attackable)
        most_hated = mob.most_hated

        unless @baium.try &.alive?
          mob.delete_me
          return super
        end

        if most_hated && most_hated.player? && @zone.inside_zone?(most_hated)
          if mob.target != most_hated
            mob.clear_aggro_list
          end
          add_attack_desire(mob, most_hated)
        else
          found = false
          mob.known_list.each_character(1000) do |char|
            if char.playable? && @zone.inside_zone?(char) && char.alive?
              if mob.target != char
                mob.clear_aggro_list
              end
              add_attack_desire(mob, char)
              found = true
              break
            end
          end

          unless found
            if mob.inside_radius?(@baium.not_nil!, 40, true, false)
              if mob.target != @baium
                mob.clear_aggro_list
              end
              mob.running = true
              mob.add_damage_hate(@baium.not_nil!, 0, 999)
              mob.set_intention(AI::ATTACK, @baium.not_nil!)
            else
              mob.set_intention(AI::FOLLOW, @baium.not_nil!)
            end
          end
        end
        start_quest_timer("SELECT_TARGET", 5000, npc, nil)
      end
    when "CHECK_ATTACK"
      if npc && @last_attack + 1800000 < Time.ms
        cancel_quest_timers("SELECT_TARGET")
        notify_event("CLEAR_ZONE", nil, nil)
        add_spawn(BAIUM_STONE, BAIUM_LOC, false, 0)
        set_status(ALIVE)
      elsif npc
        if @last_attack + 300000 < Time.ms && npc.hp_percent < 75
          npc.target = npc
          npc.do_cast(HEAL_OF_BAIUM)
        end
        start_quest_timer("CHECK_ATTACK", 60000, npc, nil)
      end
    when "CLEAR_STATUS"
      set_status(ALIVE)
      add_spawn(BAIUM_STONE, BAIUM_LOC, false, 0)
    when "CLEAR_ZONE"
      @zone.characters_inside.each do |char|
        if char.npc?
          char.delete_me
        elsif char.player?
          notify_event("teleportOut", nil, char.as(L2PcInstance))
        end
      end
    when "RESPAWN_BAIUM"
      if get_status == DEAD
        set_respawn(0)
        cancel_quest_timer("CLEAR_STATUS", nil, nil)
        notify_event("CLEAR_STATUS", nil, nil)
      else
        player.not_nil!.send_message("#{self.class.simple_name}: You can't respawn Baium while Baium is alive.")
      end
    when "ABORT_FIGHT"
      if get_status == IN_FIGHT
        @baium = nil
        notify_event("CLEAR_ZONE", nil, nil)
        notify_event("CLEAR_STATUS", nil, nil)
        player.not_nil!.send_message("#{self.class.simple_name}: Aborting fight.")
      else
        player.not_nil!.send_message("#{self.class.simple_name}: You can't abort attack right now.")
      end
      cancel_quest_timers("CHECK_ATTACK")
      cancel_quest_timers("SELECT_TARGET")
    when "DESPAWN_MINIONS"
      if get_status == IN_FIGHT
        @zone.characters_inside.each do |char|
          if char.npc? && char.id == ARCHANGEL
            char.delete_me
          end
        end
        if player
          player.send_message("#{self.class.simple_name}: All archangels has been deleted.")
        end
      elsif player
        player.send_message("#{self.class.simple_name}: You can't despawn archangels right now.")
      end
    when "MANAGE_SKILLS"
      if npc
        manage_skills(npc)
      end
    end


    super
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    @last_attack = Time.ms

    if npc.id == BAIUM
      if attacker.mount_type.strider? && !attacker.affected_by_skill?(ANTI_STRIDER.skill_id)
        unless npc.skill_disabled?(ANTI_STRIDER.skill)
          npc.target = attacker
          npc.do_cast(ANTI_STRIDER)
        end
      end

      if skill.nil?
        refresh_ai_params(attacker, npc, damage.to_i64 * 1000)
      elsif npc.hp_percent < 25
        refresh_ai_params(attacker, npc, (damage // 3) * 100)
      elsif npc.hp_percent < 50
        refresh_ai_params(attacker, npc, damage * 20)
      elsif npc.hp_percent < 75
        refresh_ai_params(attacker, npc, (damage * 10))
      else
        refresh_ai_params(attacker, npc, (damage // 3) * 20)
      end
      manage_skills(npc)
    else
      mob = npc.as(L2Attackable)
      most_hated = mob.most_hated

      if Rnd.rand(100) < 10 && mob.check_do_cast_conditions(SPEAR_ATTACK.skill)
        if most_hated && npc.calculate_distance(most_hated, true, false) < 1000 && @zone.character_in_zone?(most_hated)
          mob.target = most_hated
          mob.do_cast(SPEAR_ATTACK)
        elsif @zone.character_in_zone?(attacker)
          mob.target = attacker
          mob.do_cast(SPEAR_ATTACK)
        end
      end

      if Rnd.rand(100) < 5 && npc.hp_percent < 50
        if mob.check_do_cast_conditions(ANGEL_HEAL.skill)
          npc.target = npc
          npc.do_cast(ANGEL_HEAL)
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if @zone.character_in_zone?(killer)
      set_status(DEAD)
      add_spawn(TELE_CUBE, TELEPORT_CUBIC_LOC, false, 900000)
      @zone.broadcast_packet(Music::BS01_D_10000.packet)
      respawn_time = (Config.baium_spawn_interval.to_i64 + Rnd.rand(-Config.baium_spawn_random..Config.baium_spawn_random)) * 3600000
      set_respawn(respawn_time)
      start_quest_timer("CLEAR_STATUS", respawn_time, nil, nil)
      start_quest_timer("CLEAR_ZONE", 900000, nil, nil)
      cancel_quest_timer("CHECK_ATTACK", npc, nil)
      cancel_quest_timers("SELECT_TARGET")
    end

    super
  end

  def on_see_creature(npc, creature, is_summon)
    if !@zone.inside_zone?(creature) || (creature.npc? && creature.id == BAIUM_STONE)
      return super
    end

    if creature.in_category?(CategoryType::CLERIC_GROUP)
      if npc.hp_percent < 25
        refresh_ai_params(creature, npc, 10000)
      elsif npc.hp_percent < 50
        refresh_ai_params(creature, npc, 10000, 6000)
      elsif npc.hp_percent < 75
        refresh_ai_params(creature, npc, 10000, 3000)
      else
        refresh_ai_params(creature, npc, 10000, 2000)
      end
    else
      refresh_ai_params(creature, npc, 10000, 1000)
    end

    manage_skills(npc)
    super
  end

  def on_spell_finished(npc, pc, skill)
    start_quest_timer("MANAGE_SKILLS", 1000, npc, nil)

    unless @zone.character_in_zone?(npc)
      @baium.try &.tele_to_location(BAIUM_LOC)
    end

    super
  end

  def unload(remove_from_list)
    @baium.try &.delete_me
    super
  end

  private def refresh_ai_params(attacker, npc, damage, aggro = damage)
    new_aggro_val = damage + Rnd.rand(3000)
    aggro_val = aggro + 1000
    vars = npc.variables
    3.times do |i|
      if attacker == vars.get_object("c_quest#{i}", L2Character?)
        if vars.get_i32("i_quest#{i}") < aggro_val
          vars["i_quest#{i}"] = new_aggro_val
        end

        return
      end
    end
    index = Util.get_index_of_min_value(vars.get_i32("i_quest0"), vars.get_i32("i_quest1"), vars.get_i32("i_quest2"))
    vars["i_quest#{index}"] = new_aggro_val
    vars["c_quest#{index}"] = attacker
  end

  private def get_status
    GrandBossManager.get_boss_status(BAIUM)
  end

  private def add_boss(boss)
    GrandBossManager.add_boss(boss)
  end

  private def set_status(status)
    GrandBossManager.set_boss_status(BAIUM, status)
  end

  private def set_respawn(respawn_time)
    stats_set = GrandBossManager.get_stats_set(BAIUM).not_nil!
    stats_set["respawn_time"] = Time.ms + respawn_time
  end

  private def manage_skills(npc)
    if npc.casting_now? || npc.core_ai_disabled? || !npc.in_combat?
      return
    end

    vars = npc.variables
    3.times do |i|
      attacker = vars.get_object("c_quest#{i}", L2Character?)
      if attacker.nil? || (npc.calculate_distance(attacker, true, false) > 9000 || attacker.dead?)
        vars["i_quest#{i}"] = 0
      end
    end
    index = Util.get_index_of_max_value(vars.get_i32("i_quest0"), vars.get_i32("i_quest1"), vars.get_i32("i_quest2"))
    player = vars.get_object("c_quest#{index}", L2Character?)
    i2 = vars.get_i32("i_quest#{index}")
    if i2 > 0 && Rnd.rand(100) < 70
      vars["i_quest#{index}"] = 500
    end

    if player && player.alive?
      if npc.current_hp > npc.max_hp * 0.75
        if Rnd.rand(100) < 10
          skill_to_cast = ENERGY_WAVE
        elsif Rnd.rand(100) < 10
          skill_to_cast = EARTH_QUAKE
        else
          skill_to_cast = BAIUM_ATTACK
        end
      elsif npc.current_hp > npc.max_hp * 0.5
        if Rnd.rand(100) < 10
          skill_to_cast = GROUP_HOLD
        elsif Rnd.rand(100) < 10
          skill_to_cast = ENERGY_WAVE
        elsif Rnd.rand(100) < 10
          skill_to_cast = EARTH_QUAKE
        else
          skill_to_cast = BAIUM_ATTACK
        end
      elsif npc.current_hp > npc.max_hp * 0.25
        if Rnd.rand(100) < 10
          skill_to_cast = THUNDERBOLT
        elsif Rnd.rand(100) < 10
          skill_to_cast = GROUP_HOLD
        elsif Rnd.rand(100) < 10
          skill_to_cast = ENERGY_WAVE
        elsif Rnd.rand(100) < 10
          skill_to_cast = EARTH_QUAKE
        else
          skill_to_cast = BAIUM_ATTACK
        end
      elsif Rnd.rand(100) < 10
        skill_to_cast = THUNDERBOLT
      elsif Rnd.rand(100) < 10
        skill_to_cast = GROUP_HOLD
      elsif Rnd.rand(100) < 10
        skill_to_cast = ENERGY_WAVE
      elsif Rnd.rand(100) < 10
        skill_to_cast = EARTH_QUAKE
      else
        skill_to_cast = BAIUM_ATTACK
      end
    end

    if skill_to_cast && npc.check_do_cast_conditions(skill_to_cast.skill)
      npc.target = player
      npc.do_cast(skill_to_cast)
    end
  end

  private def get_random_player(npc)
    npc.known_list.each_player(2000) do |pc|
      if @zone.inside_zone?(pc) && pc.alive?
        return pc
      end
    end

    nil
  end
end
