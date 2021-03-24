class Scripts::IceQueensCastle < AbstractInstance
  private class IQCWorld < InstanceWorld
    property! player : L2PcInstance?
  end

  # NPCs
  private FREYA = 18847
  private BATTALION_LEADER = 18848
  private LEGIONNAIRE = 18849
  private MERCENARY_ARCHER = 18926
  private ARCHERY_KNIGHT = 22767
  private JINIA = 32781
  # Locations
  private START_LOC = Location.new(114000, -112357, -11200, 0, 0)
  private EXIT_LOC = Location.new(113883, -108777, -848, 0, 0)
  private FREYA_LOC = Location.new(114730, -114805, -11200, 50, 0)
  # Skill
  private ETHERNAL_BLIZZARD = SkillHolder.new(6276)
  # Misc
  private TEMPLATE_ID = 137
  private ICE_QUEEN_DOOR = 23140101
  private MIN_LV = 82

  def initialize
    super(self.class.simple_name)

    add_start_npc(JINIA)
    add_talk_id(JINIA)
    add_see_creature_id(BATTALION_LEADER, LEGIONNAIRE, MERCENARY_ARCHER)
    add_spawn_id(FREYA)
    add_spell_finished_id(FREYA)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "ATTACK_KNIGHT"
      npc = npc.not_nil!
      npc.known_list.known_characters do |char|
        if char.id == ARCHERY_KNIGHT && char.alive? && !char.as(L2Attackable).decayed?
          npc.running = true
          npc.set_intention(AI::ATTACK, char)
          npc.as(L2Attackable).add_damage_hate(char, 0, 999999)
          break
        end
      end
      start_quest_timer("ATTACK_KNIGHT", 3000, npc, nil)
    when "TIMER_MOVING"
      if npc
        npc.set_intention(AI::MOVE_TO, FREYA_LOC)
      end
    when "TIMER_BLIZZARD"
      npc = npc.not_nil!
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::I_CAN_NO_LONGER_STAND_BY)
      npc.stop_move(nil)
      npc.target = pc
      npc.do_cast(ETHERNAL_BLIZZARD)
    when "TIMER_SCENE_21"
      if npc
        pc = pc.not_nil!
        pc.show_quest_movie(21)
        npc.delete_me
        start_quest_timer("TIMER_PC_LEAVE", 24_000, npc, pc)
      end
    when "TIMER_PC_LEAVE"
      pc = pc.not_nil!
      if qs = pc.get_quest_state(Q10285_MeetingSirra.simple_name)
        qs.memo_state = 3
        qs.set_cond(10, true)
        world = InstanceManager.get_player_world(pc).not_nil!
        world.remove_allowed(pc.l2id)
        pc.instance_id = 0
        pc.tele_to_location(EXIT_LOC, 0)
      end
    end

    super
  end

  def on_see_creature(npc, creature, is_summon)
    if creature.player? && npc.script_value?(0)
      npc.known_list.known_characters do |char|
        if char.id == ARCHERY_KNIGHT && char.alive? && !char.as(L2Attackable).decayed?
          npc.running = true
          npc.set_intention(AI::ATTACK, char)
          npc.as(L2Attackable).add_damage_hate(char, 0, 999999)
          npc.script_value = 1
          start_quest_timer("ATTACK_KNIGHT", 5000, npc, nil)
          break
        end
      end
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::S1_MAY_THE_PROTECTION_OF_THE_GODS_BE_UPON_YOU, creature.name)
    end

    super
  end

  def on_spawn(npc)
    start_quest_timer("TIMER_MOVING", 60_000, npc, nil)
    start_quest_timer("TIMER_BLIZZARD", 180_000, npc, nil)

    super
  end

  def on_spell_finished(npc, pc, skill)
    world = InstanceManager.get_world(npc.instance_id)

    if world.is_a?(IQCWorld)
      if skill == ETHERNAL_BLIZZARD.skill && world.player?
        start_quest_timer("TIMER_SCENE_21", 1000, npc, world.player)
      end
    end

    super
  end

  def on_talk(npc, talker)
    enter_instance(talker, IQCWorld.new, "IceQueensCastle.xml", TEMPLATE_ID)
    super
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      world.add_allowed(pc.l2id)
      world.as(IQCWorld).player = pc
      open_door(ICE_QUEEN_DOOR, world.instance_id)
    end

    teleport_player(pc, START_LOC, world.instance_id, false)
  end

  private def check_conditions(pc)
    if pc.level < MIN_LV
      sm = SystemMessage.c1_s_level_requirement_is_not_sufficient_and_cannot_be_entered
      sm.add_string(pc.name)
      pc.send_packet(sm)
      return false
    end

    true
  end
end
