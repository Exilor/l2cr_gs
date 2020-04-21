class Scripts::IceQueensCastleNormalBattle < AbstractInstance
  private class IQCNBWorld < InstanceWorld
    getter players_inside = [] of L2PcInstance
    getter knight_statues = [] of L2Npc
    getter spawned_mobs = Concurrent::Array(L2Attackable).new
    property! controller : L2NpcInstance?
    property! supp_jinia : L2QuestGuardInstance?
    property! supp_kegor : L2QuestGuardInstance?
    property! freya : L2GrandBossInstance?
    property? support_active = false
    property? can_spawn_mobs = true
    property? hard_mode = false
  end

  # Npcs
  private FREYA_THRONE = 29177
  private FREYA_SPELLING = 29178
  private FREYA_STAND = 29179
  private FREYA_STAND_ULTIMATE = 29180
  private INVISIBLE_NPC = 18919
  private KNIGHT = 18855
  private KNIGHT_ULTIMATE = 18856
  private GLACIER = 18853
  private BREATH = 18854
  private GLAKIAS = 25699
  private GLAKIAS_ULTIMATE = 25700
  private SIRRA = 32762
  private JINIA = 32781
  private SUPP_JINIA = 18850
  private SUPP_KEGOR = 18851
  # Skills
  private ETERNAL_BLIZZARD = SkillHolder.new(6274)
  private ETERNAL_BLIZZARD_HARD = SkillHolder.new(6275)
  private ETERNAL_BLIZZARD_FORCE = SkillHolder.new(6697)
  private BREATH_OF_ICE_PALACE = SkillHolder.new(6299)
  private SELF_DESTRUCTION = SkillHolder.new(6300)
  private JINIAS_PRAYER = SkillHolder.new(6288)
  private KEGORS_COURAGE = SkillHolder.new(6289)
  private COLD_MANAS_FRAGMENT = SkillHolder.new(6301)
  private NPC_CANCEL_PC_TARGET = SkillHolder.new(4618)
  private POWER_STRIKE = SkillHolder.new(6293)
  private POINT_TARGET = SkillHolder.new(6295)
  private CYLINDER_THROW = SkillHolder.new(6297)
  private LEADERS_ROAR = SkillHolder.new(6294)
  private RUSH = SkillHolder.new(6296)
  private HINDER_STRIDER = SkillHolder.new(4258)
  private ICE_BALL = SkillHolder.new(6278)
  private SUMMON_SPIRITS = SkillHolder.new(6277)
  private ATTACK_NEARBY_RANGE = SkillHolder.new(6279)
  private REFLECT_MAGIC = SkillHolder.new(6282)
  private RAGE_OF_ICE = SkillHolder.new(6285)
  private FREYAS_BLESS = SkillHolder.new(6284)
  # Locations
  private FREYA_SPAWN = Location.new(114720, -117085, -11088, 15956)
  private FREYA_SPELLING_SPAWN = Location.new(114723, -117502, -10672, 15956)
  private FREYA_CORPSE = Location.new(114767, -114795, -11200, 0)
  private MIDDLE_POINT = Location.new(114730, -114805, -11200)
  private KEGOR_FINISH = Location.new(114659, -114796, -11205)
  private GLAKIAS_SPAWN = Location.new(114707, -114799, -11199, 15956)
  private SUPP_JINIA_SPAWN = Location.new(114751, -114781, -11205)
  private SUPP_KEGOR_SPAWN = Location.new(114659, -114796, -11205)
  private BATTLE_PORT = Location.new(114694, -113700, -11200)
  private CONTROLLER_LOC = Location.new(114394, -112383, -11200)
  private ENTER_LOC = {
    Location.new(114185, -112435, -11210),
    Location.new(114183, -112280, -11210),
    Location.new(114024, -112435, -11210),
    Location.new(114024, -112278, -11210),
    Location.new(113865, -112435, -11210),
    Location.new(113865, -112276, -11210)
  }
  private STATUES_LOC = {
    Location.new(113845, -116091, -11168, 8264),
    Location.new(113381, -115622, -11168, 8264),
    Location.new(113380, -113978, -11168, -8224),
    Location.new(113845, -113518, -11168, -8224),
    Location.new(115591, -113516, -11168, -24504),
    Location.new(116053, -113981, -11168, -24504),
    Location.new(116061, -115611, -11168, 24804),
    Location.new(115597, -116080, -11168, 24804),
    Location.new(112942, -115480, -10960, 52),
    Location.new(112940, -115146, -10960, 52),
    Location.new(112945, -114453, -10960, 52),
    Location.new(112945, -114123, -10960, 52),
    Location.new(116497, -114117, -10960, 32724),
    Location.new(116499, -114454, -10960, 32724),
    Location.new(116501, -115145, -10960, 32724),
    Location.new(116502, -115473, -10960, 32724)
  }
  private KNIGHTS_LOC = {
    Location.new(114502, -115315, -11205, 15451),
    Location.new(114937, -115323, -11205, 18106),
    Location.new(114722, -115185, -11205, 16437)
  }
  # Misc
  private MAX_PLAYERS = 27
  private MIN_PLAYERS = 10
  private MIN_LEVEL = 82
  private TEMPLATE_ID = 139 # Ice Queen's Castle
  private TEMPLATE_ID_ULTIMATE = 144 # Ice Queen's Castle (Ultimate Battle)
  private DOOR_ID = 23140101

  def initialize
    super(self.class.simple_name)

    add_start_npc(SIRRA, SUPP_KEGOR, SUPP_JINIA)
    add_first_talk_id(SUPP_KEGOR, SUPP_JINIA)
    add_talk_id(SIRRA, JINIA, SUPP_KEGOR)
    add_attack_id(
      FREYA_THRONE, FREYA_STAND, FREYA_STAND_ULTIMATE, GLAKIAS,
      GLAKIAS_ULTIMATE, GLACIER, BREATH, KNIGHT, KNIGHT_ULTIMATE
    )
    add_kill_id(
      GLAKIAS, GLAKIAS_ULTIMATE, FREYA_STAND, FREYA_STAND_ULTIMATE, KNIGHT,
      KNIGHT_ULTIMATE, GLACIER, BREATH
    )
    add_spawn_id(
      GLAKIAS, GLAKIAS_ULTIMATE, FREYA_STAND, FREYA_STAND_ULTIMATE, KNIGHT,
      KNIGHT_ULTIMATE, GLACIER, BREATH
    )
    add_spell_finished_id(GLACIER, BREATH)
  end

  def on_adv_event(event, npc, player)
    if event == "enter"
      enter_instance(player.not_nil!, IQCNBWorld.new, "IceQueensCastleNormalBattle.xml", TEMPLATE_ID)
    elsif event == "enterUltimate"
      enter_instance(player.not_nil!, IQCNBWorld.new, "IceQueensCastleUltimateBattle.xml", TEMPLATE_ID_ULTIMATE)
    else
      npc = npc.not_nil!
      world = InstanceManager.get_world(npc.instance_id)
      if world.is_a?(IQCNBWorld)
        case event
        when "openDoor"
          if npc.script_value?(0)
            npc.script_value = 1
            open_door(DOOR_ID, world.instance_id)
            world.controller = add_spawn(INVISIBLE_NPC, CONTROLLER_LOC, false, 0, true, world.instance_id).as(L2NpcInstance)
            STATUES_LOC.each do |loc|
              if loc.z == -11168
                statue = add_spawn(INVISIBLE_NPC, loc, false, 0, false, world.instance_id)
                world.knight_statues << statue
              end
            end

            unless world.hard_mode?
              world.players_inside.each do |plr|
                if plr.alive? && plr.instance_id == world.instance_id
                  qs = player.not_nil!.get_quest_state(Q10286_ReunionWithSirra.simple_name)
                  if qs && qs.state == State::STARTED && qs.cond?(5)
                    qs.set_cond(6, true)
                  end
                end
              end
            end
            start_quest_timer("STAGE_1_MOVIE", 60000, world.controller, nil)
          end
        when "portInside"
          teleport_player(player.not_nil!, BATTLE_PORT, world.instance_id)
        when "killFreya"
          qs = player.not_nil!.get_quest_state(Q10286_ReunionWithSirra.simple_name)
          if qs && qs.state == State::STARTED && qs.cond?(6)
            qs.memo_state = 10
            qs.set_cond(7, true)
          end
          world.supp_kegor.delete_me
          world.freya.decay_me
          manage_movie(world, 20)
          cancel_quest_timer("FINISH_WORLD", world.controller, nil)
          start_quest_timer("FINISH_WORLD", 58500, world.controller, nil)
        when "18851-01.html"
          return event
        when "STAGE_1_MOVIE"
          close_door(DOOR_ID, world.instance_id)
          world.status = 1
          manage_movie(world, 15)
          start_quest_timer("STAGE_1_START", 53500, world.controller, nil)
        when "STAGE_1_START"
          world.freya = add_spawn(FREYA_THRONE, FREYA_SPAWN, false, 0, true, world.instance_id).as(L2GrandBossInstance)
          world.freya.mortal = false
          manage_screen_msg(world, NpcString::BEGIN_STAGE_1)
          start_quest_timer("CAST_BLIZZARD", 50000, world.controller, nil)
          start_quest_timer("STAGE_1_SPAWN", 2000, world.freya, nil)
        when "STAGE_1_SPAWN"
          notify_event("START_SPAWN", world.controller, nil)
        when "STAGE_1_FINISH"
          world.freya.delete_me
          world.freya = nil
          manage_despawn_minions(world)
          manage_movie(world, 16)
          start_quest_timer("STAGE_1_PAUSE", 24100 - 1000, world.controller, nil)
        when "STAGE_1_PAUSE"
          world.freya = add_spawn(FREYA_SPELLING, FREYA_SPELLING_SPAWN, false, 0, true, world.instance_id).as(L2GrandBossInstance)
          world.freya.invul = true
          world.freya.disable_core_ai(true)
          manage_timer(world, 60, NpcString::TIME_REMAINING_UNTIL_NEXT_BATTLE)
          world.status = 2
          start_quest_timer("STAGE_2_START", 60000, world.controller, nil)
        when "STAGE_2_START"
          world.can_spawn_mobs = true
          notify_event("START_SPAWN", world.controller, nil)
          manage_screen_msg(world, NpcString::BEGIN_STAGE_2)

          if world.hard_mode?
            start_quest_timer("STAGE_2_FAILED", 360000, world.controller, nil)
            manage_timer(world, 360, NpcString::BATTLE_END_LIMIT_TIME)
            world.controller.variables["TIMER_END"] = Time.ms + 360000
          end
        when "STAGE_2_MOVIE"
          manage_movie(world, 23)
          start_quest_timer("STAGE_2_GLAKIAS", 7000, world.controller, nil)
        when "STAGE_2_GLAKIAS"
          STATUES_LOC.each do |loc|
            if loc.z == -10960
              statue = add_spawn(INVISIBLE_NPC, loc, false, 0, false, world.instance_id)
              world.knight_statues << statue
              start_quest_timer("SPAWN_KNIGHT", 5000, statue, nil)
            end
          end
          glakias = add_spawn(world.hard_mode? ? GLAKIAS_ULTIMATE : GLAKIAS, GLAKIAS_SPAWN, false, 0, true, world.instance_id).as(L2RaidBossInstance)
          start_quest_timer("LEADER_DELAY", 5000, glakias, nil)

          if world.hard_mode?
            start_quest_timer("SHOW_GLAKIAS_TIMER", 3000, world.controller, nil)
          end
        when "STAGE_2_FAILED"
          manage_movie(world, 22)
          start_quest_timer("STAGE_2_FAILED2", 22000, npc, nil)
        when "STAGE_2_FAILED2"
          InstanceManager.destroy_instance(world.instance_id)
        when "STAGE_3_MOVIE"
          manage_movie(world, 17)
          start_quest_timer("STAGE_3_START", 21500, world.controller, nil)
        when "STAGE_3_START"
          world.players_inside.each do |plr|
            plr.broadcast_packet(ExChangeClientEffectInfo::FREYA_DESTROYED)
          end
          world.status = 4
          world.freya.delete_me
          world.can_spawn_mobs = true
          world.freya = add_spawn(world.hard_mode? ? FREYA_STAND_ULTIMATE : FREYA_STAND, FREYA_SPAWN, false, 0, true, world.instance_id).as(L2GrandBossInstance)
          world.controller.variables["FREYA_MOVE"] = 0
          notify_event("START_SPAWN", world.controller, nil)
          start_quest_timer("START_MOVE", 10000, world.controller, nil)
          start_quest_timer("CAST_BLIZZARD", 50000, world.controller, nil)
          manage_screen_msg(world, NpcString::BEGIN_STAGE_3)

          if world.hard_mode?
            world.freya.do_cast(RAGE_OF_ICE)
            start_quest_timer("FREYA_BUFF", 15000, world.controller, nil)
          end
        when "FREYA_BUFF"
          world.freya.do_cast(FREYAS_BLESS)
          start_quest_timer("FREYA_BUFF", 15000, world.controller, nil)
        when "START_MOVE"
          if npc.variables.get_i32("FREYA_MOVE") == 0
            world.controller.variables["FREYA_MOVE"] = 1
            world.freya.running = true
            world.freya.set_intention(AI::MOVE_TO, MIDDLE_POINT)
          end
        when "CAST_BLIZZARD"
          unless world.freya.invul?
            blizzard_force_count = world.controller.variables.get_i32("BLIZZARD_FORCE_COUNT", 0)
            if world.hard_mode? && blizzard_force_count < 4 && world.freya.current_hp < world.freya.max_hp * (0.8 - (0.2 * blizzard_force_count))
              world.controller.variables["BLIZZARD_FORCE_COUNT"] = blizzard_force_count + 1
              world.freya.do_cast(ETERNAL_BLIZZARD_FORCE)
              manage_screen_msg(world, NpcString::MAGIC_POWER_SO_STRONG_THAT_IT_COULD_MAKE_YOU_LOSE_YOUR_MIND_CAN_BE_FELT_FROM_SOMEWHERE)
            else
              sh = world.hard_mode? ? ETERNAL_BLIZZARD_HARD : ETERNAL_BLIZZARD
              world.freya.do_cast(sh.skill)
              manage_screen_msg(world, NpcString::STRONG_MAGIC_POWER_CAN_BE_FELT_FROM_SOMEWHERE)
            end
          end

          time = world.hard_mode? ? Rnd.rand(35..40) : Rnd.rand(55..60) * 1000
          start_quest_timer("CAST_BLIZZARD", time, world.controller, nil)

          world.spawned_mobs.each do |minion|
            if minion.alive? && !minion.in_combat?
              manage_random_attack(world, minion)
            end
          end
        when "SPAWN_SUPPORT"
          world.players_inside.each do |plr|
            plr.invul = false
          end
          world.freya.invul = false
          world.freya.disable_core_ai(false)
          manage_screen_msg(world, NpcString::BEGIN_STAGE_4)
          world.supp_jinia = add_spawn(SUPP_JINIA, SUPP_JINIA_SPAWN, false, 0, true, world.instance_id).as(L2QuestGuardInstance)
          world.supp_jinia.running = true
          world.supp_jinia.invul = true
          world.supp_jinia.can_return_to_spawn_point = false
          world.supp_kegor = add_spawn(SUPP_KEGOR, SUPP_KEGOR_SPAWN, false, 0, true, world.instance_id).as(L2QuestGuardInstance)
          world.supp_kegor.running = true
          world.supp_kegor.invul = true
          world.supp_kegor.can_return_to_spawn_point = false
          start_quest_timer("ATTACK_FREYA", 5000, world.supp_jinia, nil)
          start_quest_timer("ATTACK_FREYA", 5000, world.supp_kegor, nil)
          start_quest_timer("GIVE_SUPPORT", 1000, world.controller, nil)
        when "GIVE_SUPPORT"
          if world.support_active?
            world.supp_jinia.do_cast(JINIAS_PRAYER)
            world.supp_kegor.do_cast(KEGORS_COURAGE)
            start_quest_timer("GIVE_SUPPORT", 25000, world.controller, nil)
          end
        when "FINISH_STAGE"
          world.supp_jinia.delete_me
          world.supp_jinia = nil
          world.freya.tele_to_location(FREYA_CORPSE)
          world.supp_kegor.tele_to_location(KEGOR_FINISH)
        when "START_SPAWN"
          world.knight_statues.each do |statues|
            notify_event("SPAWN_KNIGHT", statues, nil)
          end

          KNIGHTS_LOC.each do |loc|
            knight = add_spawn(world.hard_mode? ? KNIGHT_ULTIMATE : KNIGHT, loc, false, 0, false, world.instance_id).as(L2Attackable)
            knight.disable_core_ai(true)
            knight.display_effect = 1
            knight.spawn.location = loc
            world.spawned_mobs << knight
            start_quest_timer("ICE_RUPTURE", Rnd.rand(2..5) * 1000, knight, nil)
          end

          world.status.times do |i|
            notify_event("SPAWN_GLACIER", world.controller, nil)
          end
        when "SPAWN_KNIGHT"
          if world.can_spawn_mobs?
            loc = Location.new(MIDDLE_POINT.x + Rnd.rand(-1000..1000), MIDDLE_POINT.y + Rnd.rand(-1000..1000), MIDDLE_POINT.z)
            knight = add_spawn(world.hard_mode? ? KNIGHT_ULTIMATE : KNIGHT, npc.location, false, 0, false, world.instance_id).as(L2Attackable)
            knight.variables["SPAWNED_NPC"] = npc
            knight.disable_core_ai(true)
            knight.immobilized = true
            knight.display_effect = 1
            knight.spawn.location = loc
            world.spawned_mobs << knight
            time = world.hard_mode? ? Rnd.rand(5..10) : Rnd.rand(15..20) * 1000
            start_quest_timer("ICE_RUPTURE", time, knight, nil)
          end
        when "SPAWN_GLACIER"
          if world.can_spawn_mobs?
            loc = Location.new(MIDDLE_POINT.x + Rnd.rand(-1000..1000), MIDDLE_POINT.y + Rnd.rand(-1000..1000), MIDDLE_POINT.z)
            glacier = add_spawn(GLACIER, loc, false, 0, false, world.instance_id).as(L2Attackable)
            glacier.display_effect = 1
            glacier.disable_core_ai(true)
            glacier.immobilized = true
            world.spawned_mobs << glacier
            start_quest_timer("CHANGE_STATE", 1400, glacier, nil)
          end
        when "ICE_RUPTURE"
          if npc.core_ai_disabled?
            unless npc.is_a?(L2Attackable)
              raise "Expected #{npc} to be a L2Attackable."
            end
            npc.disable_core_ai(false)
            npc.immobilized = false
            npc.display_effect = 2
            manage_random_attack(world, npc)
          end
        when "FIND_TARGET"
          unless npc.is_a?(L2Attackable)
            raise "Expected #{npc} to be a L2Attackable."
          end
          manage_random_attack(world, npc)
        when "CHANGE_STATE"
          npc.display_effect = 2
          start_quest_timer("CAST_SKILL", 20000, npc, nil)
        when "CAST_SKILL"
          if npc.script_value?(0) && npc.alive?
            npc.target = npc
            npc.do_cast(COLD_MANAS_FRAGMENT)
            npc.script_value = 1
          end
        when "SUICIDE"
          npc.display_effect = 3
          npc.mortal = true
          npc.do_die(nil)
        when "BLIZZARD"
          npc.variables["SUICIDE_COUNT"] = npc.variables.get_i32("SUICIDE_COUNT") + 1

          if npc.variables.get_i32("SUICIDE_ON") == 0
            if npc.variables.get_i32("SUICIDE_COUNT") == 2
              start_quest_timer("ELEMENTAL_SUICIDE", 20000, npc, nil)
            else
              if npc.check_do_cast_conditions(BREATH_OF_ICE_PALACE.skill) && !npc.casting_now?
                npc.target = npc
                npc.do_cast(BREATH_OF_ICE_PALACE)
              end
              start_quest_timer("BLIZZARD", 20000, npc, nil)
            end
          end
        when "ELEMENTAL_SUICIDE"
          npc.target = npc
          npc.do_cast(SELF_DESTRUCTION)
        when "ELEMENTAL_KILLED"
          if npc.variables.get_i32("SUICIDE_ON") == 1
            npc.target = npc
            npc.do_cast(SELF_DESTRUCTION)
          end
        when "ATTACK_FREYA"
          skill = npc.template.get_skill_holder("Skill01_ID").not_nil!
          if npc.inside_radius?(world.freya, 100, true, false)
            if npc.check_do_cast_conditions(skill.skill) && !npc.casting_now?
              npc.target = world.freya
              npc.do_cast(skill)
              start_quest_timer("ATTACK_FREYA", 20000, npc, nil)
            else
              start_quest_timer("ATTACK_FREYA", 5000, npc, nil)
            end
          else
            npc.set_intention(AI::FOLLOW, world.freya)
            start_quest_timer("ATTACK_FREYA", 5000, npc, nil)
          end
        when "FINISH_WORLD"
          if freya = world.freya?
            freya.decay_me
          end

          world.players_inside.each do |plr|
            plr.broadcast_packet(ExChangeClientEffectInfo::FREYA_DEFAULT)
          end
          InstanceManager.destroy_instance(world.instance_id)
        when "LEADER_RANGEBUFF"
          if npc.check_do_cast_conditions(LEADERS_ROAR.skill) && !npc.casting_now?
            npc.target = npc
            npc.do_cast(LEADERS_ROAR)
          else
            start_quest_timer("LEADER_RANGEBUFF", 30000, npc, nil)
          end
        when "LEADER_RANDOMIZE"
          unless npc.is_a?(L2Attackable)
            raise "Expected #{npc} to be a L2Attackable."
          end
          npc.clear_aggro_list

          npc.known_list.each_character(1000) do |char|
            npc.add_damage_hate(char, 0, Rnd.rand(10000..20000))
          end
          start_quest_timer("LEADER_RANDOMIZE", 25000, npc, nil)
        when "LEADER_DASH"
          unless npc.is_a?(L2Attackable)
            raise "Expected #{npc} to be a L2Attackable."
          end
          most_hated = npc.most_hated
          if Rnd.bool && !npc.casting_now? && most_hated && most_hated.alive? && npc.calculate_distance(most_hated, true, false) < 1000
            npc.target = most_hated
            npc.do_cast(RUSH)
          end
          start_quest_timer("LEADER_DASH", 10000, npc, nil)
        when "LEADER_DESTROY"
          unless npc.is_a?(L2Attackable)
            raise "Expected #{npc} to be a L2Attackable."
          end
          if npc.variables.get_i32("OFF_SHOUT") == 0
            manage_screen_msg(world, NpcString::THE_SPACE_FEELS_LIKE_ITS_GRADUALLY_STARTING_TO_SHAKE)

            case Rnd.rand(4)
            when 0
              broadcast_npc_say(npc, Say2::SHOUT, NpcString::ARCHER_GIVE_YOUR_BREATH_FOR_THE_INTRUDER)
            when 1
              broadcast_npc_say(npc, Say2::SHOUT, NpcString::MY_KNIGHTS_SHOW_YOUR_LOYALTY)
            when 2
              broadcast_npc_say(npc, Say2::SHOUT, NpcString::I_CAN_TAKE_IT_NO_LONGER)
            when 3
              broadcast_npc_say(npc, Say2::SHOUT, NpcString::ARCHER_HEED_MY_CALL)
              3.times do |i|
                breath = add_spawn(BREATH, npc.location, true, 0, false, world.instance_id).as(L2Attackable)
                breath.running = true
                breath.add_damage_hate(npc.most_hated, 0, 999)
                breath.set_intention(AI::ATTACK, npc.most_hated)
                start_quest_timer("BLIZZARD", 20000, breath, nil)
                world.spawned_mobs << breath
              end
            else
              # [automatically added else]
            end

          end
        when "LEADER_DELAY"
          if npc.variables.get_i32("DELAY_VAL") == 0
            npc.variables["DELAY_VAL"] = 1
          end
        when "SHOW_GLAKIAS_TIMER"
          time = ((world.controller.variables.get_i64("TIMER_END", 0) - Time.ms) / 1000).to_i32
          manage_timer(world, time, NpcString::BATTLE_END_LIMIT_TIME)
        else
          # [automatically added else]
        end

      end
    end

    super
  end

  def on_spawn(npc)
    unless npc.is_a?(L2Attackable)
      raise "Expected #{npc} to be a L2Attackable."
    end
    npc.on_kill_delay = 0
    super
  end

  def on_first_talk(npc, pc)
    world = InstanceManager.get_world(npc.instance_id)

    if world.is_a?(IQCNBWorld)
      if npc.id == SUPP_JINIA
        pc.action_failed
        return
      elsif npc.id == SUPP_KEGOR
        if world.support_active?
          pc.action_failed
          return
        end
        return "18851.html"
      end
    end
    pc.action_failed

    nil
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(IQCNBWorld)
      case npc.id
      when FREYA_THRONE
        if world.controller.variables.get_i32("FREYA_MOVE") == 0 && world.status?(1)
          world.controller.variables["FREYA_MOVE"] = 1
          manage_screen_msg(world, NpcString::FREYA_HAS_STARTED_TO_MOVE)
          world.freya.running = true
          world.freya.set_intention(AI::MOVE_TO, MIDDLE_POINT)
        end

        if npc.hp_percent < 20
          notify_event("STAGE_1_FINISH", world.controller, nil)
          cancel_quest_timer("CAST_BLIZZARD", world.controller, nil)
        else
          if attacker.mount_type.strider? && !attacker.affected_by_skill?(HINDER_STRIDER.skill_id) && !npc.casting_now?
            unless npc.skill_disabled?(HINDER_STRIDER.skill)
              npc.target = attacker
              npc.do_cast(HINDER_STRIDER)
            end
          end

          most_hated = npc.as(L2Attackable).most_hated
          can_reach_most_hated = most_hated && most_hated.alive? && npc.calculate_distance(most_hated, true, false) <= 800

          if Rnd.rand(10000) < 3333
            if Rnd.bool
              if npc.calculate_distance(attacker, true, false) <= 800 && npc.check_do_cast_conditions(ICE_BALL.skill) && !npc.casting_now?
                npc.target = attacker
                npc.do_cast(ICE_BALL)
              end
            else
              if can_reach_most_hated && npc.check_do_cast_conditions(ICE_BALL.skill) && !npc.casting_now?
                npc.target = most_hated
                npc.do_cast(ICE_BALL)
              end
            end
          elsif Rnd.rand(10000) < 800
            if Rnd.bool
              if npc.calculate_distance(attacker, true, false) <= 800 && npc.check_do_cast_conditions(SUMMON_SPIRITS.skill) && !npc.casting_now?
                npc.target = attacker
                npc.do_cast(SUMMON_SPIRITS)
              end
            else
              if can_reach_most_hated && npc.check_do_cast_conditions(SUMMON_SPIRITS.skill) && !npc.casting_now?
                npc.target = most_hated
                npc.do_cast(SUMMON_SPIRITS)
              end
            end
          elsif Rnd.rand(10000) < 1500
            if !npc.affected_by_skill?(ATTACK_NEARBY_RANGE.skill_id) && npc.check_do_cast_conditions(ATTACK_NEARBY_RANGE.skill) && !npc.casting_now?
              npc.target = npc
              npc.do_cast(ATTACK_NEARBY_RANGE)
            end
          end
        end
      when FREYA_STAND, FREYA_STAND_ULTIMATE
        if world.controller.variables.get_i32("FREYA_MOVE") == 0
          world.controller.variables["FREYA_MOVE"] = 1
          world.freya.running = true
          world.freya.set_intention(AI::MOVE_TO, MIDDLE_POINT)
        end

        if npc.hp_percent < 20 && !world.support_active?
          world.support_active = true
          world.freya.invul = true
          world.freya.disable_core_ai(true)
          world.players_inside.each do |plr|
            plr.invul = true
            plr.abort_attack
          end
          manage_movie(world, 18)
          start_quest_timer("SPAWN_SUPPORT", 27000, world.controller, nil)
        end

        if attacker.mount_type.strider? && !attacker.affected_by_skill?(HINDER_STRIDER.skill_id) && !npc.casting_now?
          unless npc.skill_disabled?(HINDER_STRIDER.skill)
            npc.target = attacker
            npc.do_cast(HINDER_STRIDER)
          end
        end

        most_hated = npc.as(L2Attackable).most_hated
        can_reach_most_hated = most_hated && most_hated.alive? && npc.calculate_distance(most_hated, true, false) <= 800

        if Rnd.rand(10000) < 3333
          if Rnd.bool
            if npc.calculate_distance(attacker, true, false) <= 800
              if npc.check_do_cast_conditions(ICE_BALL.skill)
                unless npc.casting_now?
                  npc.target = attacker
                  npc.do_cast(ICE_BALL)
                end
              end
            end
          else
            if can_reach_most_hated
              if npc.check_do_cast_conditions(ICE_BALL.skill)
                unless npc.casting_now?
                  npc.target = most_hated
                  npc.do_cast(ICE_BALL)
                end
              end
            end
          end
        elsif Rnd.rand(10000) < 1333
          if Rnd.bool
            if npc.calculate_distance(attacker, true, false) <= 800
              if npc.check_do_cast_conditions(SUMMON_SPIRITS.skill)
                unless npc.casting_now?
                  npc.target = attacker
                  npc.do_cast(SUMMON_SPIRITS)
                end
              end
            end
          else
            if can_reach_most_hated
              if npc.check_do_cast_conditions(SUMMON_SPIRITS.skill)
                unless npc.casting_now?
                  npc.target = most_hated
                  npc.do_cast(SUMMON_SPIRITS)
                end
              end
            end
          end
        elsif Rnd.rand(10000) < 1500
          unless npc.affected_by_skill?(ATTACK_NEARBY_RANGE.skill_id)
            if npc.check_do_cast_conditions(ATTACK_NEARBY_RANGE.skill)
              unless npc.casting_now?
                npc.target = npc
                npc.do_cast(ATTACK_NEARBY_RANGE)
              end
            end
          end
        elsif Rnd.rand(10000) < 1333
          unless npc.affected_by_skill?(REFLECT_MAGIC.skill_id)
            if npc.check_do_cast_conditions(REFLECT_MAGIC.skill)
              unless npc.casting_now?
                npc.target = npc
                npc.do_cast(REFLECT_MAGIC)
              end
            end
          end
        end
      when GLACIER
        if npc.script_value?(0) && npc.hp_percent < 50
          npc.target = attacker
          npc.do_cast(COLD_MANAS_FRAGMENT)
          npc.script_value = 1
        end
      when BREATH
        if npc.current_hp < npc.max_hp / 20
          if npc.variables.get_i32("SUICIDE_ON", 0) == 0
            npc.variables["SUICIDE_ON"] = 1
            start_quest_timer("ELEMENTAL_KILLED", 1000, npc, nil)
          end
        end
      when KNIGHT, KNIGHT_ULTIMATE
        if npc.core_ai_disabled?
          manage_random_attack(world, npc.as(L2Attackable))
          npc.disable_core_ai(false)
          npc.immobilized = false
          npc.display_effect = 2
          cancel_quest_timer("ICE_RUPTURE", npc, nil)
        end
      when GLAKIAS, GLAKIAS_ULTIMATE
        if npc.hp_percent < 20
          if npc.variables.get_i32("OFF_SHOUT") == 0
            npc.variables["OFF_SHOUT"] = 1
            npc.variables["DELAY_VAL"] = 2
            npc.target = attacker
            npc.do_cast(NPC_CANCEL_PC_TARGET)
          elsif npc.variables.get_i32("OFF_SHOUT") == 1
            npc.target = attacker
            npc.do_cast(NPC_CANCEL_PC_TARGET)
          end
        elsif npc.variables.get_i32("OFF_SHOUT") == 0 && npc.variables.get_i32("DELAY_VAL") == 1
          most_hated = npc.as(L2Attackable).most_hated
          can_reach_most_hated = most_hated && most_hated.alive? && npc.calculate_distance(most_hated, true, false) < 1000

          if npc.variables.get_i32("TIMER_ON") == 0
            npc.variables["TIMER_ON"] = 1
            start_quest_timer("LEADER_RANGEBUFF", Rnd.rand(5..30) * 1000, npc, nil)
            start_quest_timer("LEADER_RANDOMIZE", 25000, npc, nil)
            start_quest_timer("LEADER_DASH", 5000, npc, nil)
            start_quest_timer("LEADER_DESTROY", 60000, npc, nil)
          end

          if Rnd.rand(10000) < 2500
            if Rnd.rand(10000) < 2500
              if npc.check_do_cast_conditions(POWER_STRIKE.skill) && !npc.casting_now?
                npc.target = attacker
                npc.do_cast(POWER_STRIKE)
              end
            elsif npc.check_do_cast_conditions(POWER_STRIKE.skill) && !npc.casting_now? && can_reach_most_hated
              npc.target = npc.as(L2Attackable).most_hated
              npc.do_cast(POWER_STRIKE)
            end
          elsif Rnd.rand(10000) < 1500
            if Rnd.bool
              if npc.check_do_cast_conditions(POINT_TARGET.skill) && !npc.casting_now?
                npc.target = attacker
                npc.do_cast(POINT_TARGET)
              end
            elsif npc.check_do_cast_conditions(POINT_TARGET.skill) && !npc.casting_now? && can_reach_most_hated
              npc.target = npc.as(L2Attackable).most_hated
              npc.do_cast(POINT_TARGET)
            end
          elsif Rnd.rand(10000) < 1500
            if Rnd.bool
              if npc.check_do_cast_conditions(CYLINDER_THROW.skill) && !npc.casting_now?
                npc.target = attacker
                npc.do_cast(CYLINDER_THROW)
              end
            elsif npc.check_do_cast_conditions(CYLINDER_THROW.skill) && !npc.casting_now? && can_reach_most_hated
              npc.target = npc.as(L2Attackable).most_hated
              npc.do_cast(CYLINDER_THROW)
            end
          end
        end
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_spell_finished(npc, pc, skill)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(IQCNBWorld)
      case npc.id
      when GLACIER
        if skill == COLD_MANAS_FRAGMENT.skill
          if Rnd.rand(100) < 75
            breath = add_spawn(BREATH, npc.location, false, 0, false, world.instance_id).as(L2Attackable)
            if pc
              breath.running = true
              breath.add_damage_hate(pc, 0, 999)
              breath.set_intention(AI::ATTACK, pc)
            else
              manage_random_attack(world, breath)
            end
            world.spawned_mobs << breath
            start_quest_timer("BLIZZARD", 20000, breath, nil)
          end
          notify_event("SUICIDE", npc, nil)
        end
      when BREATH
        if skill == SELF_DESTRUCTION.skill
          npc.do_die(nil)
        end
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_kill(npc, killer, is_summon)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(IQCNBWorld)
      case npc.id
      when GLAKIAS, GLAKIAS_ULTIMATE
        manage_despawn_minions(world)
        manage_timer(world, 60, NpcString::TIME_REMAINING_UNTIL_NEXT_BATTLE)
        cancel_quest_timer("STAGE_2_FAILED", world.controller, nil)
        start_quest_timer("STAGE_3_MOVIE", 60000, world.controller, nil)
      when FREYA_STAND, FREYA_STAND_ULTIMATE
        world.support_active = false
        manage_movie(world, 19)
        manage_despawn_minions(world)
        finish_instance(world)
        DecayTaskManager.cancel(world.freya)
        cancel_quest_timer("ATTACK_FREYA", world.supp_jinia, nil)
        cancel_quest_timer("ATTACK_FREYA", world.supp_kegor, nil)
        cancel_quest_timer("GIVE_SUPPORT", world.controller, nil)
        cancel_quest_timer("CAST_BLIZZARD", world.controller, nil)
        cancel_quest_timer("FREYA_BUFF", world.controller, nil)
        start_quest_timer("FINISH_STAGE", 16000, world.controller, nil)
        start_quest_timer("FINISH_WORLD", 300000, world.controller, nil)
      when KNIGHT, KNIGHT_ULTIMATE
        spawned_by = npc.variables.get_object("SPAWNED_NPC", L2Npc?)
        var = world.controller.variables
        knight_count = var.get_i32("KNIGHT_COUNT")

        if var.get_i32("FREYA_MOVE") == 0 && world.status?(1)
          var["FREYA_MOVE"] = 1
          manage_screen_msg(world, NpcString::FREYA_HAS_STARTED_TO_MOVE)
          world.freya.running = true
          world.freya.set_intention(AI::MOVE_TO, MIDDLE_POINT)
        end

        if knight_count < 10 && world.status?(2)
          knight_count += 1
          var["KNIGHT_COUNT"] = knight_count

          if knight_count == 10
            notify_event("STAGE_2_MOVIE", world.controller, nil)
            world.status = 3
          end
        end

        if spawned_by
          time = world.hard_mode? ? Rnd.rand(30..60) : Rnd.rand(50..60) * 1000
          start_quest_timer("SPAWN_KNIGHT", time, spawned_by, nil)
        end
        world.spawned_mobs.delete_first(npc)
      when GLACIER
        start_quest_timer("SPAWN_GLACIER", Rnd.rand(30..60) * 1000, world.controller, nil)
        world.spawned_mobs.delete_first(npc)
      when BREATH
        world.spawned_mobs.delete_first(npc)
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      world = world.as(IQCNBWorld)
      world.hard_mode = world.template_id == TEMPLATE_ID_ULTIMATE
      party = pc.party
      cc = party.try &.command_channel
      if party.nil?
        manage_player_enter(pc, world)
      elsif cc
        cc.members.each do |m|
          manage_player_enter(m, world)
        end
      else
        party.members.each do |m|
          manage_player_enter(m, world)
        end
      end
    else
      if world.status?(4)
        teleport_player(pc, BATTLE_PORT, world.instance_id)
      else
        teleport_player(pc, ENTER_LOC.sample(random: Rnd), world.instance_id)
      end
    end
  end

  private def manage_player_enter(pc, world)
    world.players_inside << pc
    world.add_allowed(pc.l2id)
    teleport_player(pc, ENTER_LOC.sample(random: Rnd), world.instance_id, false)
  end

  private def check_conditions(pc)
    party = pc.party
    channel = party.try &.command_channel

    if pc.override_instance_conditions?
      return true
    end

    if party.nil?
      pc.send_packet(SystemMessageId::NOT_IN_PARTY_CANT_ENTER)
      return false
    elsif channel.nil?
      pc.send_packet(SystemMessageId::NOT_IN_COMMAND_CHANNEL_CANT_ENTER)
      return false
    elsif pc != channel.leader
      pc.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      return false
    elsif !channel.size.between?(MIN_PLAYERS, MAX_PLAYERS)
      pc.send_packet(SystemMessageId::PARTY_EXCEEDED_THE_LIMIT_CANT_ENTER)
      return false
    end

    channel.members.each do |m|
      if m.level < MIN_LEVEL
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      elsif !Util.in_range?(1000, pc, m, true)
        sm = SystemMessage.c1_is_in_a_location_which_cannot_be_entered_therefore_it_cannot_be_processed
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      elsif Time.ms < InstanceManager.get_instance_time(m.l2id, TEMPLATE_ID)
        sm = SystemMessage.c1_may_not_re_enter_yet
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      elsif Time.ms < InstanceManager.get_instance_time(m.l2id, TEMPLATE_ID_ULTIMATE)
        sm = SystemMessage.c1_may_not_re_enter_yet
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
    end

    true
  end

  private def manage_random_attack(world, mob)
    players = world.players_inside.select do |pc|
      pc.alive? && pc.instance_id == world.instance_id && !pc.invisible?
    end

    players.shuffle!(random: Rnd)

    if target = players.first?
      mob.add_damage_hate(target, 0, 999)
      mob.running = true
      mob.set_intention(AI::ATTACK, target)
    else
      start_quest_timer("FIND_TARGET", 10000, mob, nil)
    end
  end

  private def manage_despawn_minions(world)
    world.can_spawn_mobs = false
    world.spawned_mobs.each do |mob|
      if mob.alive?
        mob.do_die(nil)
      end
    end
  end

  private def manage_timer(world, time, npc_string)
    world.players_inside.each do |pc|
      if pc.instance_id == world.instance_id
        pc.send_packet(ExSendUIEvent.new(pc, false, false, time, 0, npc_string))
      end
    end
  end

  private def manage_screen_msg(world, string_id)
    world.players_inside.each do |pc|
      if pc.instance_id == world.instance_id
        show_on_screen_msg(pc, string_id, 2, 6000)
      end
    end
  end

  private def manage_movie(world, movie)
    world.players_inside.each do |pc|
      if pc.instance_id == world.instance_id
        pc.show_quest_movie(movie)
      end
    end
  end
end
