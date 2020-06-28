class Scripts::Valakas < AbstractNpcAI
  # NPC
  private VALAKAS = 29028
  # Skills
  private HINDER_STRIDER = SkillHolder.new(4258)
  private VALAKAS_LAVA_SKIN = SkillHolder.new(4680)
  private VALAKAS_REGENERATION_1 = SkillHolder.new(4691)
  private VALAKAS_REGENERATION_2 = SkillHolder.new(4691, 2)
  private VALAKAS_REGENERATION_3 = SkillHolder.new(4691, 3)
  private VALAKAS_REGENERATION_4 = SkillHolder.new(4691, 4)

  private VALAKAS_REGULAR_SKILLS = {
    SkillHolder.new(4681), # Valakas Trample
    SkillHolder.new(4682), # Valakas Trample
    SkillHolder.new(4683), # Valakas Dragon Breath
    SkillHolder.new(4689)  # Valakas Fear TODO: has two levels only level one is used.
  }

  private VALAKAS_LOWHP_SKILLS = {
    SkillHolder.new(4681), # Valakas Trample
    SkillHolder.new(4682), # Valakas Trample
    SkillHolder.new(4683), # Valakas Dragon Breath
    SkillHolder.new(4689), # Valakas Fear TODO: has two levels only level one is used.
    SkillHolder.new(4690)  # Valakas Meteor Storm
  }

  private VALAKAS_AOE_SKILLS = {
    SkillHolder.new(4683), # Valakas Dragon Breath
    SkillHolder.new(4684), # Valakas Dragon Breath
    SkillHolder.new(4685), # Valakas Tail Stomp
    SkillHolder.new(4686), # Valakas Tail Stomp
    SkillHolder.new(4688), # Valakas Stun
    SkillHolder.new(4689), # Valakas Fear TODO: has two levels only level one is used.
    SkillHolder.new(4690)  # Valakas Meteor Storm
  }

  # Locations
  private TELEPORT_CUBE_LOCATIONS = {
    Location.new(214880, -116144, -1644),
    Location.new(213696, -116592, -1644),
    Location.new(212112, -116688, -1644),
    Location.new(211184, -115472, -1664),
    Location.new(210336, -114592, -1644),
    Location.new(211360, -113904, -1644),
    Location.new(213152, -112352, -1644),
    Location.new(214032, -113232, -1644),
    Location.new(214752, -114592, -1644),
    Location.new(209824, -115568, -1421),
    Location.new(210528, -112192, -1403),
    Location.new(213120, -111136, -1408),
    Location.new(215184, -111504, -1392),
    Location.new(215456, -117328, -1392),
    Location.new(213200, -118160, -1424)
  }
  private ATTACKER_REMOVE = Location.new(150037, -57255, -2976)
  private VALAKAS_LAIR = Location.new(212852, -114842, -1632)
  private VALAKAS_REGENERATION_LOC = Location.new(-105200, -253104, -15264)
  # Valakas status.
  private DORMANT = 0 # Valakas is spawned and no one has entered yet. Entry is unlocked.
  private WAITING = 1 # Valakas is spawned and someone has entered, triggering a 30 minute window for additional people to enter. Entry is unlocked.
  private FIGHTING = 2 # Valakas is engaged in battle, annihilating his foes. Entry is locked.
  private DEAD = 3 # Valakas has been killed. Entry is locked.
  # Misc
  @time_tracker = 0i64
  @valakas_target : L2Playable?

  private getter! zone : L2BossZone

  def initialize
    super(self.class.simple_name, "ai/individual")

    register_mobs(VALAKAS)

    @zone = GrandBossManager.get_zone(212852, -114842, -1632).not_nil!
    info = GrandBossManager.get_stats_set(VALAKAS).not_nil!
    status = GrandBossManager.get_boss_status(VALAKAS)

    if status == DEAD
      temp = info.get_i64("respawn_time") - Time.ms
      if temp > 0
        start_quest_timer("valakas_unlock", temp, nil, nil)
      else
        valakas = add_spawn(VALAKAS, -105200, -253104, -15264, 0, false, 0)
        GrandBossManager.set_boss_status(VALAKAS, DORMANT)
        GrandBossManager.add_boss(valakas.as(L2GrandBossInstance))

        valakas.invul = true
        valakas.set_running

        valakas.intention = AI::IDLE
      end
    else
      loc_x = info.get_i32("loc_x")
      loc_y = info.get_i32("loc_y")
      loc_z = info.get_i32("loc_z")
      heading = info.get_i32("heading")
      hp = info.get_i32("currentHP")
      mp = info.get_i32("currentMP")

      valakas = add_spawn(VALAKAS, loc_x, loc_y, loc_z, heading, false, 0)
      GrandBossManager.add_boss(valakas.as(L2GrandBossInstance))

      valakas.set_current_hp_mp(hp.to_f, mp.to_f)
      valakas.set_running

      # Start timers.
      if status == FIGHTING
        # stores current time for inactivity task.
        @time_tracker = Time.ms

        start_quest_timer("regen_task", 60000, valakas, nil, true)
        start_quest_timer("skill_task", 2000, valakas, nil, true)
      else
        valakas.invul = true
        valakas.intention = AI::IDLE

        # Start timer to lock entry after 30 minutes
        if status == WAITING
          start_quest_timer("beginning", Config.valakas_wait_time * 60000, valakas, nil)
        end
      end
    end
  end

  def on_adv_event(event, npc, pc)
    if npc
      case event.casecmp
      when "beginning"
        # Stores current time
        @time_tracker = Time.ms

        # Teleport Valakas to his lair.
        npc.tele_to_location(VALAKAS_LAIR)

        # Sound + socialAction.
        zone.players_inside.each do |pl|
          pl.send_packet(Music::BS03_A_10000.packet)
          pl.send_packet(SocialAction.new(npc.l2id, 3))
        end

        # Launch the cinematic, and tasks (regen + skill).
        start_quest_timer("spawn_1", 1700, npc, nil) # 1700
        start_quest_timer("spawn_2", 3200, npc, nil) # 1500
        start_quest_timer("spawn_3", 6500, npc, nil) # 3300
        start_quest_timer("spawn_4", 9400, npc, nil) # 2900
        start_quest_timer("spawn_5", 12100, npc, nil) # 2700
        start_quest_timer("spawn_6", 12430, npc, nil) # 330
        start_quest_timer("spawn_7", 15430, npc, nil) # 3000
        start_quest_timer("spawn_8", 16830, npc, nil) # 1400
        start_quest_timer("spawn_9", 23530, npc, nil) # 6700 - end of cinematic
        start_quest_timer("spawn_10", 26000, npc, nil) # 2500 - AI + unlock
        # Regeneration && inactivity task
      when "regen_task"
        # Inactivity task - 15min
        if GrandBossManager.get_boss_status(VALAKAS) == FIGHTING
          if @time_tracker + 900000 < Time.ms
            npc.intention = AI::IDLE
            npc.tele_to_location(VALAKAS_REGENERATION_LOC)

            GrandBossManager.set_boss_status(VALAKAS, DORMANT)
            npc.set_current_hp_mp(npc.max_hp.to_f, npc.max_mp.to_f)

            # Drop all players from the zone.
            zone.oust_all_players

            # Cancel skill_task and regen_task.
            cancel_quest_timer("regen_task", npc, nil)
            cancel_quest_timer("skill_task", npc, nil)
            return
          end
        end

        # Verify if "Valakas Regeneration" skill is active.
        info = npc.effect_list.get_buff_info_by_skill_id(VALAKAS_REGENERATION_1.skill_id)
        lvl = info ? info.skill.level : 0

        # Current HPs are inferior to 25% ; apply lvl 4 of regen skill.
        if npc.current_hp < npc.max_hp // 4 && lvl != 4
          npc.target = npc
          npc.do_cast(VALAKAS_REGENERATION_4)
        # Current HPs are inferior to 50% ; apply lvl 3 of regen skill.
        elsif npc.current_hp < (npc.max_hp * 2) / 4.0 && lvl != 3
          npc.target = npc
          npc.do_cast(VALAKAS_REGENERATION_3)
        # Current HPs are inferior to 75% ; apply lvl 2 of regen skill.
        elsif npc.current_hp < (npc.max_hp * 3) / 4.0 && lvl != 2
          npc.target = npc
          npc.do_cast(VALAKAS_REGENERATION_2)
        # Apply lvl 1.
        elsif lvl != 1
          npc.target = npc
          npc.do_cast(VALAKAS_REGENERATION_1)
        end
      # Spawn cinematic, regen_task and choose of skill.
      when "spawn_1"
        zone.broadcast_packet(SpecialCamera.new(npc, 1800, 180, -1, 1500, 15000, 10000, 0, 0, 1, 0, 0))
      when "spawn_2"
        zone.broadcast_packet(SpecialCamera.new(npc, 1300, 180, -5, 3000, 15000, 10000, 0, -5, 1, 0, 0))
      when "spawn_3"
        zone.broadcast_packet(SpecialCamera.new(npc, 500, 180, -8, 600, 15000, 10000, 0, 60, 1, 0, 0))
      when "spawn_4"
        zone.broadcast_packet(SpecialCamera.new(npc, 800, 180, -8, 2700, 15000, 10000, 0, 30, 1, 0, 0))
      when "spawn_5"
        zone.broadcast_packet(SpecialCamera.new(npc, 200, 250, 70, 0, 15000, 10000, 30, 80, 1, 0, 0))
      when "spawn_6"
        zone.broadcast_packet(SpecialCamera.new(npc, 1100, 250, 70, 2500, 15000, 10000, 30, 80, 1, 0, 0))
      when "spawn_7"
        zone.broadcast_packet(SpecialCamera.new(npc, 700, 150, 30, 0, 15000, 10000, -10, 60, 1, 0, 0))
      when "spawn_8"
        zone.broadcast_packet(SpecialCamera.new(npc, 1200, 150, 20, 2900, 15000, 10000, -10, 30, 1, 0, 0))
      when "spawn_9"
        zone.broadcast_packet(SpecialCamera.new(npc, 750, 170, -10, 3400, 15000, 4000, 10, -15, 1, 0, 0))
      when "spawn_10"
        GrandBossManager.set_boss_status(VALAKAS, FIGHTING)
        npc.invul = false

        start_quest_timer("regen_task", 60000, npc, nil, true)
        start_quest_timer("skill_task", 2000, npc, nil, true)
      # Death cinematic, spawn of Teleport Cubes.
      when "die_1"
        zone.broadcast_packet(SpecialCamera.new(npc, 2000, 130, -1, 0, 15000, 10000, 0, 0, 1, 1, 0))
      when "die_2"
        zone.broadcast_packet(SpecialCamera.new(npc, 1100, 210, -5, 3000, 15000, 10000, -13, 0, 1, 1, 0))
      when "die_3"
        zone.broadcast_packet(SpecialCamera.new(npc, 1300, 200, -8, 3000, 15000, 10000, 0, 15, 1, 1, 0))
      when "die_4"
        zone.broadcast_packet(SpecialCamera.new(npc, 1000, 190, 0, 500, 15000, 10000, 0, 10, 1, 1, 0))
      when "die_5"
        zone.broadcast_packet(SpecialCamera.new(npc, 1700, 120, 0, 2500, 15000, 10000, 12, 40, 1, 1, 0))
      when "die_6"
        zone.broadcast_packet(SpecialCamera.new(npc, 1700, 20, 0, 700, 15000, 10000, 10, 10, 1, 1, 0))
      when "die_7"
        zone.broadcast_packet(SpecialCamera.new(npc, 1700, 10, 0, 1000, 15000, 10000, 20, 70, 1, 1, 0))
      when "die_8"
        zone.broadcast_packet(SpecialCamera.new(npc, 1700, 10, 0, 300, 15000, 250, 20, -20, 1, 1, 0))

        TELEPORT_CUBE_LOCATIONS.each do |loc|
          add_spawn(31759, loc, false, 900000)
        end

        start_quest_timer("remove_players", 900000, nil, nil)
      when "skill_task"
        call_skill_ai(npc)
      end

    else
      case event.casecmp
      when "valakas_unlock"
         valakas = add_spawn(VALAKAS, -105200, -253104, -15264, 32768, false, 0)
        GrandBossManager.add_boss(valakas.as(L2GrandBossInstance))
        GrandBossManager.set_boss_status(VALAKAS, DORMANT)
      when "remove_players"
        zone.oust_all_players
      end

    end

    super
  end

  def on_spawn(npc)
    npc.disable_core_ai(true)
    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    unless zone.inside_zone?(attacker)
      attacker.do_die(attacker)
      return
    end

    if npc.invul?
      return
    end

    if GrandBossManager.get_boss_status(VALAKAS) != FIGHTING
      attacker.tele_to_location(ATTACKER_REMOVE)
      return
    end

    # Debuff strider-mounted players.
    if attacker.mount_type.strider?
      unless attacker.affected_by_skill?(HINDER_STRIDER.skill_id)
        npc.target = attacker
        npc.do_cast(HINDER_STRIDER)
      end
    end

    @time_tracker = Time.ms

    super
  end

  def on_kill(npc, killer, is_summon)
    # Cancel skill_task and regen_task.
    cancel_quest_timer("regen_task", npc, nil)
    cancel_quest_timer("skill_task", npc, nil)

    # Launch death animation.
    zone.broadcast_packet(Music::B03_D_10000.packet)
    zone.broadcast_packet(SpecialCamera.new(npc, 1200, 20, -10, 0, 10000, 13000, 0, 0, 0, 0, 0))

    start_quest_timer("die_1", 300, npc, nil) # 300
    start_quest_timer("die_2", 600, npc, nil) # 300
    start_quest_timer("die_3", 3800, npc, nil) # 3200
    start_quest_timer("die_4", 8200, npc, nil) # 4400
    start_quest_timer("die_5", 8700, npc, nil) # 500
    start_quest_timer("die_6", 13300, npc, nil) # 4600
    start_quest_timer("die_7", 14000, npc, nil) # 700
    start_quest_timer("die_8", 16500, npc, nil) # 2500

    GrandBossManager.set_boss_status(VALAKAS, DEAD)
    # Calculate Min and Max respawn times randomly.
    min = -Config.valakas_spawn_random
    max = Config.valakas_spawn_random
    respawn_time = Config.valakas_spawn_interval + Rnd.rand(min..max)
    respawn_time *= 3600000

    start_quest_timer("valakas_unlock", respawn_time, nil, nil)
    # also save the respawn time so that the info is maintained past reboots
    info = GrandBossManager.get_stats_set(VALAKAS).not_nil!
    info["respawn_time"] = Time.ms + respawn_time
    GrandBossManager.set_stats_set(VALAKAS, info)

    super
  end

  def on_aggro_range_enter(npc, pc, is_summon)
    # return nil
  end

  private def call_skill_ai(npc)
    if npc.invul? || npc.casting_now?
      return
    end

    # Pickup a target if no or dead victim. 10% luck he decides to reconsiders his target.
    t = @valakas_target
    if t.nil? || (t.dead? || !npc.known_list.knows_object?(t) || Rnd.rand(10) == 0)
      @valakas_target = get_rand_target(npc)
    end

    # If result is still nil, Valakas will roam. Don't go deeper in skill AI.
    if @valakas_target.nil?
      if Rnd.rand(10) == 0
        x = npc.x
        y = npc.y
        z = npc.z

        pos_x = x + Rnd.rand(-1400..1400)
        pos_y = y + Rnd.rand(-1400..1400)

        if GeoData.can_move?(x, y, z, pos_x, pos_y, z, npc.instance_id)
          npc.set_intention(AI::MOVE_TO, Location.new(pos_x, pos_y, z, 0))
        end
      end

      return
    end

    skill = get_rand_skill(npc)

    # Cast the skill or follow the target.
    range = (skill.skill.cast_range < 600) ? 600 : skill.skill.cast_range
    if Util.in_range?(range, npc, @valakas_target, true)
      npc.intention = AI::IDLE
      npc.casting_now = true
      npc.target = @valakas_target
      npc.do_cast(skill)
    else
      npc.set_intention(AI::FOLLOW, @valakas_target, nil)
      npc.casting_now = false
    end
  end

  # Valakas will mostly use utility skills. If Valakas feels surrounded, he will
  # use AoE skills.
  # Lower than 50% HP, he will begin to use Meteor skill.
  private def get_rand_skill(npc) : SkillHolder
    hp_ratio = npc.hp_percent

    # Valakas Lava Skin has priority.
    if hp_ratio < 75 && Rnd.rand(150) == 0
      unless npc.affected_by_skill?(VALAKAS_LAVA_SKIN.skill_id)
        return VALAKAS_LAVA_SKIN
      end
    end

    # Valakas will use AOE spells if he feels surrounded.
    if Util.get_players_count_in_radius(1200, npc, false, false) >= 20
      return VALAKAS_AOE_SKILLS.sample(random: Rnd)
    end

    if hp_ratio > 50
      return VALAKAS_REGULAR_SKILLS.sample(random: Rnd)
    end

    VALAKAS_LOWHP_SKILLS.sample(random: Rnd)
  end

  private def get_rand_target(npc)
    result = [] of L2Playable

    npc.known_list.each_character do |obj|
      if obj.pet?
        next
      elsif obj.alive? && obj.is_a?(L2Playable)
        result << obj
      end
    end

    result.sample?(random: Rnd)
  end
end
