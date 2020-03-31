require "../../instances/abstract_instance"

class Scripts::HallOfSuffering < AbstractInstance
  private class HOSWorld < InstanceWorld
    property npc_list = {} of L2Npc => Bool
    property start_time = 0i64
    property party_leader_name = ""
    property reward_item_id = -1
    property reward_htm = ""
    property! klodekus : L2Npc?
    property! klanikus : L2Npc?
    property? bosses_attacked = false
    property? rewarded = false
  end

  # NPCs
  private MOUTH_OF_EKIMUS = 32537
  private TEPIOS = 32530
  # Location
  private ENTER_TELEPORT = Location.new(-187567, 205570, -9538)
  # Skill
  private PRESENTATION_DISTRICT1_BOSS_ARISE = SkillHolder.new(5824)
  # Monsters
  private KLODEKUS = 25665
  private KLANIKUS = 25666
  private TUMOR_ALIVE = 18704
  private TUMOR_DEAD = 18705
  private TUMOR_MOBIDS = {
    22509,
    22510,
    22511,
    22512,
    22513,
    22514,
    22515
  }
  private TWIN_MOB_IDS = {
    22509,
    22510,
    22511,
    22512,
    22513
  }
  # Doors/Walls/Zones
  private ROOM_1_MOBS = {
    {22509, -186296, 208200, -9544},
    {22509, -186161, 208345, -9544},
    {22509, -186296, 208403, -9544},
    {22510, -186107, 208113, -9528},
    {22510, -186350, 208200, -9544}
  }
  private ROOM_2_MOBS = {
    {22511, -184433, 210953, -9536},
    {22511, -184406, 211301, -9536},
    {22509, -184541, 211272, -9544},
    {22510, -184244, 211098, -9536},
    {22510, -184352, 211243, -9536},
    {22510, -184298, 211330, -9528}
  }
  private ROOM_3_MOBS = {
    {22512, -182611, 213984, -9520},
    {22512, -182908, 214071, -9520},
    {22512, -182962, 213868, -9512},
    {22509, -182881, 213955, -9512},
    {22511, -182827, 213781, -9504},
    {22511, -182530, 213984, -9528},
    {22510, -182935, 213723, -9512},
    {22510, -182557, 213868, -9520}
  }
  private ROOM_4_MOBS = {
    {22514, -180958, 216860, -9544},
    {22514, -181012, 216628, -9536},
    {22514, -181120, 216715, -9536},
    {22513, -180661, 216599, -9536},
    {22513, -181039, 216599, -9536},
    {22511, -180715, 216599, -9536},
    {22511, -181012, 216889, -9536},
    {22512, -180931, 216918, -9536},
    {22512, -180742, 216628, -9536}
  }
  private ROOM_5_MOBS = {
    {22512, -177372, 217854, -9536},
    {22512, -177237, 218140, -9536},
    {22512, -177021, 217647, -9528},
    {22513, -177372, 217792, -9544},
    {22513, -177372, 218053, -9536},
    {22514, -177291, 217734, -9544},
    {22514, -177264, 217792, -9544},
    {22514, -177264, 218053, -9536},
    {22515, -177156, 217792, -9536},
    {22515, -177075, 217647, -9528}
  }
  private TUMOR_SPAWNS = {
    Location.new(-186327, 208286, -9544),
    Location.new(-184429, 211155, -9544),
    Location.new(-182811, 213871, -9496),
    Location.new(-181039, 216633, -9528),
    Location.new(-177264, 217760, -9544)
  }
  private KLODEKUS_SPAWN = Location.new(-173727, 218169, -9536, -16384)
  private KLANIKUS_SPAWN = Location.new(-173727, 218049, -9538, 16360)
  private TEPIOS_SPAWN = Location.new(-173727, 218109, -9536)
  # Boss
  private BOSS_INVUL_TIME = 30000 # In Milliseconds.
  private BOSS_MINION_SPAWN_TIME = 60000 # In Milliseconds.
  private BOSS_RESSURECT_TIME = 20000 # In Milliseconds.
  # Misc
  private TEMPLATE_ID = 115
  private MIN_LEVEL = 75
  private MAX_LEVEL = 82

  def initialize
    super(self.class.simple_name, "gracia/instances/SeedOfInfinity")

    add_start_npc(MOUTH_OF_EKIMUS, TEPIOS)
    add_talk_id(MOUTH_OF_EKIMUS, TEPIOS)
    add_first_talk_id(TEPIOS)
    add_kill_id(TUMOR_ALIVE, KLODEKUS, KLANIKUS)
    add_attack_id(KLODEKUS, KLANIKUS)
    add_skill_see_id(TUMOR_MOBIDS)
    add_kill_id(TUMOR_MOBIDS)
  end

  private def check_conditions(pc)
    if pc.override_instance_conditions?
      return true
    end

    unless party = pc.party
      pc.send_packet(SystemMessageId::NOT_IN_PARTY_CANT_ENTER)
      return false
    end

    if party.leader != pc
      pc.send_packet(SystemMessageId::ONLY_PARTY_LEADER_CAN_ENTER)
      return false
    end

    party.members.each do |m|
      unless m.level.between?(MIN_LEVEL, MAX_LEVEL)
        sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
      unless Util.in_range?(1000, pc, m, true)
        sm = SystemMessage.c1_is_in_a_location_which_cannot_be_entered_therefore_it_cannot_be_processed
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
      if Time.ms < InstanceManager.get_instance_time(m.l2id, TEMPLATE_ID)
        sm = SystemMessage.c1_may_not_re_enter_yet
        sm.add_pc_name(m)
        party.broadcast_packet(sm)
        return false
      end
    end

    true
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      if party = pc.party
        party.members.each do |m|
          teleport_player(m, ENTER_TELEPORT, world.instance_id)
          world.add_allowed(m.l2id)
          get_quest_state(m, true)
        end
      else
        teleport_player(pc, ENTER_TELEPORT, world.instance_id)
        world.add_allowed(pc.l2id)
      end

      run_tumors(world.as(HOSWorld))
    else
      teleport_player(pc, ENTER_TELEPORT, world.instance_id)
    end
  end

  private def check_kill_progress(mob, world)
    if world.npc_list.has_key?(mob)
      world.npc_list[mob] = true
    end

    world.npc_list.local_each_value.all?
  end

  private def get_room_spawns(room)
    case room
    when 0
      ROOM_1_MOBS
    when 1
      ROOM_2_MOBS
    when 2
      ROOM_3_MOBS
    when 3
      ROOM_4_MOBS
    when 4
      ROOM_5_MOBS
    else
      warn { "Room #{room} not found." }
      # Slice(Slice(Int32)).empty
      Tuple.new
    end
  end

  private def run_tumors(world)
    get_room_spawns(world.status).each do |spawns|
      npc = add_spawn(*spawns, 0, false, 0, false, world.instance_id)
      world.npc_list[npc] = false
    end

    mob = add_spawn(TUMOR_ALIVE, TUMOR_SPAWNS[world.status], false, 0, false, world.instance_id)
    mob.disable_core_ai(true)
    mob.immobilized = true
    mob.current_hp = mob.max_hp * 0.5
    world.npc_list[mob] = false
    world.inc_status
  end

  private def run_twins(world)
    world.inc_status
    world.klodekus = add_spawn(KLODEKUS, KLODEKUS_SPAWN, false, 0, false, world.instance_id)
    world.klanikus = add_spawn(KLANIKUS, KLANIKUS_SPAWN, false, 0, false, world.instance_id)
    world.klanikus.mortal = false
    world.klodekus.mortal = false
  end

  private def boss_simple_die(boss)
    # killing is only possible one time
    sync do
      if boss.dead?
        return
      end
      # now reset currentHp to zero
      boss.current_hp = 0
      boss.dead = true
    end

    # Set target to nil and cancel Attack or Cast
    boss.target = nil

    # Stop movement
    boss.stop_move(nil)

    # Stop HP/MP/CP Regeneration task
    boss.status.stop_hp_mp_regeneration

    boss.stop_all_effects_except_those_that_last_through_death

    # Send the Server->Client packet StatusUpdate with current HP and MP to all other L2PcInstance to inform
    boss.broadcast_status_update

    # Notify L2Character AI
    boss.ai.notify_event(AI::DEAD)

    boss.world_region.try &.on_death(boss)
  end

  private def calc_reward_item_id(world)
    finish_diff = Time.ms - world.start_time
    if finish_diff < 1200000
      world.reward_htm = "32530-00.htm"
      world.reward_item_id = 13777
    elsif finish_diff <= 1260000
      world.reward_htm = "32530-01.htm"
      world.reward_item_id = 13778
    elsif finish_diff <= 1320000
      world.reward_htm = "32530-02.htm"
      world.reward_item_id = 13779
    elsif finish_diff <= 1380000
      world.reward_htm = "32530-03.htm"
      world.reward_item_id = 13780
    elsif finish_diff <= 1440000
      world.reward_htm = "32530-04.htm"
      world.reward_item_id = 13781
    elsif finish_diff <= 1500000
      world.reward_htm = "32530-05.htm"
      world.reward_item_id = 13782
    elsif finish_diff <= 1560000
      world.reward_htm = "32530-06.htm"
      world.reward_item_id = 13783
    elsif finish_diff <= 1620000
      world.reward_htm = "32530-07.htm"
      world.reward_item_id = 13784
    elsif finish_diff <= 1680000
      world.reward_htm = "32530-08.htm"
      world.reward_item_id = 13785
    else
      world.reward_htm = "32530-09.htm"
      world.reward_item_id = 13786
    end
  end

  private def get_party_leader_text(pc, world)
    html = HtmCache.get_htm(pc, "/data/scripts/gracia/instances/SeedOfInfinity/HallOfSuffering/32530-10.htm")
    html.not_nil!.gsub("%ptLeader%", world.party_leader_name.to_s)
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    if skill.has_effect_type?(EffectType::REBALANCE_HP, EffectType::HP)
      hate = 2 * skill.effect_point
      if hate < 2
        hate = 1000
      end
      unless npc.is_a?(L2Attackable)
        raise "Expected #{npc} to be a L2Attackable."
      end
      npc.add_damage_hate(caster, 0, hate)
    end

    super
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(HOSWorld)
      if event.casecmp?("spawnBossGuards")
        if !world.klanikus.in_combat? && !world.klodekus.in_combat?
          world.bosses_attacked = false
          return ""
        end
        unless npc.is_a?(L2Attackable)
          raise "Expected #{npc} to be a L2Attackable."
        end
        mob = add_spawn(TWIN_MOB_IDS.sample(random: Rnd), KLODEKUS_SPAWN, false, 0, false, npc.instance_id).as(L2Attackable)
        mob.add_damage_hate(npc.most_hated, 0, 1)
        if Rnd.rand(100) < 33
          mob = add_spawn(TWIN_MOB_IDS.sample(random: Rnd), KLANIKUS_SPAWN, false, 0, false, npc.instance_id).as(L2Attackable)
          mob.add_damage_hate(npc.most_hated, 0, 1)
        end
        start_quest_timer("spawnBossGuards", BOSS_MINION_SPAWN_TIME, npc, nil)
      elsif event.casecmp?("isTwinSeparated")
        if Util.in_range?(500, world.klanikus, world.klodekus, false)
          world.klanikus.invul = false
          world.klodekus.invul = false
        else
          world.klanikus.invul = true
          world.klodekus.invul = true
        end
        start_quest_timer("isTwinSeparated", 10000, npc, nil)
      elsif event.casecmp?("ressurectTwin")
        alive_twin = world.klanikus == npc ? world.klodekus : world.klanikus
        npc.do_revive
        npc.do_cast(PRESENTATION_DISTRICT1_BOSS_ARISE)
        npc.current_hp = alive_twin.current_hp

        # get most hated of other boss
        if hated = alive_twin.as(L2MonsterInstance).most_hated
          npc.ai.notify_event(AI::AGGRESSION, hated, 1000)
        end

        alive_twin.invul = true # make other boss invul
        start_quest_timer("uninvul", BOSS_INVUL_TIME, alive_twin, nil)
      elsif event == "uninvul"
        npc.invul = false
      end
    end

    ""
  end

  def on_attack(npc, attacker, damage, is_summon, skill)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(HOSWorld)
      if !world.bosses_attacked?
        world.bosses_attacked = true
        start_quest_timer("spawnBossGuards", BOSS_MINION_SPAWN_TIME, npc, nil)
        start_quest_timer("isTwinSeparated", 10000, npc, nil)
      elsif damage >= npc.current_hp
        if world.klanikus.dead?
          world.klanikus.dead = false
          world.klanikus.do_die(attacker)
          world.klodekus.do_die(attacker)
        elsif world.klodekus.dead?
          world.klodekus.dead = false
          world.klodekus.do_die(attacker)
          world.klanikus.do_die(attacker)
        else
          boss_simple_die(npc)
          start_quest_timer("ressurectTwin", BOSS_RESSURECT_TIME, npc, nil)
        end
      end
    end

    nil
  end

  def on_kill(npc, killer, is_summon)
    world = InstanceManager.get_world(npc.instance_id)
    if world.is_a?(HOSWorld)
      if npc.id == TUMOR_ALIVE
        add_spawn(TUMOR_DEAD, npc, false, 0, false, npc.instance_id)
      end
      if world.status < 5
        if check_kill_progress(npc, world)
          run_tumors(world)
        end
      elsif world.status == 5
        if check_kill_progress(npc, world)
          run_twins(world)
        end
      elsif world.status == 6 && (npc.id == KLODEKUS || npc.id == KLANIKUS)
        if world.klanikus.dead? && world.klodekus.dead?
          world.inc_status
          # instance end
          calc_reward_item_id(world)
          world.klanikus = nil
          world.klodekus = nil
          cancel_quest_timers("ressurectTwin")
          cancel_quest_timers("spawnBossGuards")
          cancel_quest_timers("isTwinSeparated")
          add_spawn(TEPIOS, TEPIOS_SPAWN, false, 0, false, world.instance_id)
          finish_instance(world)
        end
      end
    end

    super
  end

  def on_first_talk(npc, pc)
    if npc.id == TEPIOS
      world = InstanceManager.get_player_world(pc)
      if world.as(HOSWorld).reward_item_id == -1
        warn { "Hall of Suffering: #{pc.name}(#{pc.l2id}) is try to cheat!" }
        return get_party_leader_text(pc, world.as(HOSWorld))
      elsif world.as(HOSWorld).rewarded?
        return "32530-11.htm"
      elsif (party = pc.party) && party.leader_l2id == pc.l2id
        return world.as(HOSWorld).reward_htm
      end

      return get_party_leader_text(pc, world.as(HOSWorld))
    end

    super
  end

  def on_talk(npc, talker)
    get_quest_state!(talker)

    if npc.id == MOUTH_OF_EKIMUS
      enter_instance(talker, HOSWorld.new, "HallOfSuffering.xml", TEMPLATE_ID)
    elsif npc.id == TEPIOS
      world = InstanceManager.get_player_world(talker)
      if world.as(HOSWorld).reward_item_id == -1
        warn { "Hall of Suffering: #{talker.name}(#{talker.l2id}) is try to cheat!" }
        return get_party_leader_text(talker, world.as(HOSWorld))
      elsif world.as(HOSWorld).rewarded?
        return "32530-11.htm"
      elsif (party = talker.party) && party.leader_l2id == talker.l2id
        world.as(HOSWorld).rewarded = true
        party.members.each do |m|
          st = m.get_quest_state(Q00695_DefendTheHallOfSuffering.simple_name)
          if st && st.memo_state?(2)
            give_items(m, 736, 1) # Scroll of Escape
            give_items(m, world.as(HOSWorld).reward_item_id, 1)
            st.exit_quest(true)
          end
        end

        return ""
      end

      return get_party_leader_text(talker, world.as(HOSWorld))
    end

    super
  end
end
