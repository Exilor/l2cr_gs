class Scripts::GiganticGolem < AbstractNpcAI
  # NPCs
  private DR_CHAOS = 32033
  private GIGANTIC_GOLEM = 25703
  private STRANGE_MACHINE = 32032
  private GIGANTIC_BOOM_GOLEM = 25705
  # Skills
  private SMOKE = SkillHolder.new(6265)
  private EMP_SHOCK = SkillHolder.new(6263)
  private GOLEM_BOOM = SkillHolder.new(6264)
  private NPC_EARTH_SHOT = SkillHolder.new(6608)
  # Variables
  private RESPAWN = 24
  private MAX_CHASE_DIST = 3000
  private MIN_HP_PERCENTAGE = 30
  private SPAWN_FLAG = "SPAWN_FLAG"
  private ATTACK_FLAG = "ATTACK_FLAG"
  # Locations
  private PLAYER_TELEPORT = Location.new(94832, -112624, -3304)
  private DR_CHAOS_LOC = Location.new(96320, -110912, -3328, 8191)

  @last_attack = 0i64

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_first_talk_id(DR_CHAOS)
    add_kill_id(GIGANTIC_GOLEM)
    add_teleport_id(GIGANTIC_GOLEM)
    add_move_finished_id(GIGANTIC_BOOM_GOLEM)
    add_spawn_id(GIGANTIC_GOLEM, GIGANTIC_BOOM_GOLEM)
    add_attack_id(GIGANTIC_GOLEM, GIGANTIC_BOOM_GOLEM)

    remain = GlobalVariablesManager.instance.get_i64("GolemRespawn", 0i64) - Time.ms
    if remain > 0
      start_quest_timer("CLEAR_STATUS", remain, nil, nil)
    else
      start_quest_timer("CLEAR_STATUS", 1000, nil, nil)
    end
  end

  def on_adv_event(event, npc, pc)
    case event
    when "ATTACK_MACHINE"
      npc = npc.not_nil!

      SpawnTable.get_spawns(STRANGE_MACHINE).each do |sp|
        if obj = sp.last_spawn
          if npc.id == DR_CHAOS
            npc.set_intention(AI::ATTACK, obj)
            npc.broadcast_packet(SpecialCamera.new(npc, 1, -200, 15, 10000, 1000, 20000, 0, 0, 0, 0, 0))
          end
        end
      end
      start_quest_timer("ACTION_CAMERA", 10_000, npc, pc)
    when "ACTION_CAMERA"
      npc = npc.not_nil!
      start_quest_timer("MOVE_SHOW", 2500, npc, pc)
      npc.broadcast_packet(SpecialCamera.new(npc, 1, -150, 10, 3000, 1000, 20000, 0, 0, 0, 0, 0))
    when "MOVE_SHOW"
      npc = npc.not_nil!
      start_quest_timer("TELEPORT", 2000, npc, pc)
      npc.set_intention(AI::MOVE_TO, Location.new(96055, -110759, -3312, 0))
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::FOOLS_WHY_HAVENT_YOU_FLED_YET_PREPARE_TO_LEARN_A_LESSON)
    when "TELEPORT"
      pc = pc.not_nil!

      if party = pc.party
        members = party.command_channel.try &.members || party.members
        npc = npc.not_nil!
        members.each do |m|
          if m.inside_radius?(npc, 2000, true, false)
            m.tele_to_location(PLAYER_TELEPORT, true)
          end
        end
      else
        pc.tele_to_location(PLAYER_TELEPORT)
      end

      if npc && npc.id == DR_CHAOS
        npc.delete_me
      end
      start_quest_timer("WAIT_CAMERA", 1000, npc, pc)
    when "WAIT_CAMERA"
      npc = npc.not_nil!
      start_quest_timer("SPAWN_RAID", 1000, npc, pc)
      npc.broadcast_packet(SpecialCamera.new(npc, 30, -200, 20, 6000, 700, 8000, 0, 0, 0, 0, 0))
    when "SPAWN_RAID"
      add_spawn(GIGANTIC_GOLEM, 94640, -112496, -3360, 0, false, 0)
    when "FLAG"
      npc = npc.not_nil!
      npc.variables[SPAWN_FLAG] = false
    when "CORE_AI"
      if npc
        npc.as(L2Attackable).clear_aggro_list
        npc.disable_core_ai(false)
      end
    when "CLEAR_STATUS"
      add_spawn(DR_CHAOS, DR_CHAOS_LOC, false, 0)
      GlobalVariablesManager.instance["GolemRespawn"] = 0
    when "SKILL_ATTACK"
      npc = npc.not_nil!
      add_skill_cast_desire(npc, npc, SMOKE, 1_000_000)
      unless npc.variables.get_bool(ATTACK_FLAG, false)
        npc.disable_core_ai(true)
        npc.variables[ATTACK_FLAG] = true
      end
    when "MOVE_TIME"
      if npc
        npc.known_list.get_known_characters_in_radius(3000) do |obj|
          if obj.raid?
            add_move_to_desire(npc, Location.new(obj.x + Rnd.rand(-200..200), obj.y + Rnd.rand(-200..200), obj.z + 20, 0), 0)
          end
        end
      end
    when "CHECK_ATTACK"
      if @last_attack + 1_800_000 < Time.ms
        if npc
          npc.delete_me
          cancel_quest_timer("CHECK_ATTACK", npc, nil)
          start_quest_timer("CLEAR_STATUS", 1000, nil, nil)
        end
      else
        start_quest_timer("CHECK_ATTACK", 60_000, npc, nil)
      end
    end

    super
  end

  def on_first_talk(npc, pc)
    if npc.id == DR_CHAOS
      start_quest_timer("ATTACK_MACHINE", 3000, npc, pc)
      npc.set_intention(AI::MOVE_TO, Location.new(96320, -110912, -3328, 0))
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::HOW_DARE_YOU_TRESPASS_INTO_MY_TERRITORY_HAVE_YOU_NO_FEAR)
    end

    ""
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.id == GIGANTIC_BOOM_GOLEM
      npc.do_cast(GOLEM_BOOM)
    else
      @last_attack = Time.ms

      unless npc.casting_now?
        if Rnd.rand(100) < 5
          npc.do_cast(NPC_EARTH_SHOT)
        elsif Rnd.rand(100) < 1 && npc.hp_percent < MIN_HP_PERCENTAGE
          npc.do_cast(EMP_SHOCK)
        end
      end

      unless npc.variables.get_bool(SPAWN_FLAG, false)
        npc.variables[SPAWN_FLAG] = true
        pos_x = npc.x + Rnd.rand(-200..200)
        pos_y = npc.y + Rnd.rand(-200..200)
        pos_z = npc.z + 20
        6.times do
          add_spawn(GIGANTIC_BOOM_GOLEM, pos_x + Rnd.rand(-200..200), pos_y + Rnd.rand(-200..200), pos_z, 0, false, 0)
        end
        start_quest_timer("FLAG", 3_600_00, npc, nil)
      end

      if npc.calculate_distance(npc.spawn, false, false) > MAX_CHASE_DIST
        npc.disable_core_ai(true)
        npc.tele_to_location(npc.spawn)
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    respawn_time = RESPAWN * 3_600_000
    GlobalVariablesManager.instance["GolemRespawn"] = Time.ms + respawn_time
    start_quest_timer("CLEAR_STATUS", respawn_time, nil, nil)
    cancel_quest_timer("CHECK_ATTACK", npc, nil)

    super
  end

  private def on_teleport(npc)
    start_quest_timer("CORE_AI", 100, npc, nil)
  end

  def on_move_finished(npc)
    start_quest_timer("SKILL_ATTACK", 1000, npc, nil)
    start_quest_timer("MOVE_TIME", 3000, npc, nil)
  end

  def on_spawn(npc)
    if npc.id == GIGANTIC_BOOM_GOLEM
      npc.running = true
      npc.schedule_despawn(3_600_00)
      start_quest_timer("MOVE_TIME", 3000, npc, nil)
      npc.as(L2Attackable).can_return_to_spawn_point = false
    else
      @last_attack = Time.ms
      start_quest_timer("CHECK_ATTACK", 300_000, npc, nil)
      broadcast_npc_say(npc, Say2::NPC_SHOUT, NpcString::BWAH_HA_HA_YOUR_DOOM_IS_AT_HAND_BEHOLD_THE_ULTRA_SECRET_SUPER_WEAPON)
    end

    super
  end
end
