class Scripts::MithrilMine < AbstractInstance
  private class MMWorld < InstanceWorld
    property count = 0
  end

  # NPCs
  private KEGOR = 18846
  private MITHRIL_MILLIPEDE = 22766
  private KRUN = 32653
  private TARUN = 32654
  # Item
  private COLD_RESISTANCE_POTION = 15514
  # Skill
  private BLESS_OF_SWORD = SkillHolder.new(6286)
  # Location
  private START_LOC = Location.new(186852, -173492, -3763, 0, 0)
  private EXIT_LOC = Location.new(178823, -184303, -347, 0, 0)
  private MOB_SPAWNS = {
    Location.new(185216, -184112, -3308, -15396),
    Location.new(185456, -184240, -3308, -19668),
    Location.new(185712, -184384, -3308, -26696),
    Location.new(185920, -184544, -3308, -32544),
    Location.new(185664, -184720, -3308, 27892)
  }
  # Misc
  private TEMPLATE_ID = 138

  def initialize
    super(self.class.simple_name, "instances")

    add_first_talk_id(KEGOR)
    add_kill_id(KEGOR, MITHRIL_MILLIPEDE)
    add_start_npc(TARUN, KRUN)
    add_talk_id(TARUN, KRUN, KEGOR)
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    world = InstanceManager.get_world(npc.instance_id).not_nil!

    case event
    when "BUFF"
      if pc && npc.inside_radius?(pc, 1000, true, false)
        if npc.script_value?(1) && pc.alive?
          npc.target = pc
          npc.do_cast(BLESS_OF_SWORD)
        end
      end
      start_quest_timer("BUFF", 30000, npc, pc)
    when "TIMER"
      if world.is_a?(MMWorld)
        MOB_SPAWNS.each do |loc|
          mob = add_spawn(MITHRIL_MILLIPEDE, loc, false, 0, false, world.instance_id).as(L2Attackable)
          mob.script_value = 1
          mob.running = true
          mob.set_intention(AI::ATTACK, npc)
          mob.add_damage_hate(npc, 0, 999999)
        end
      end
    when "FINISH"
      npc.known_list.each_character do |char|
        if char.id == KEGOR
          kegor = char.as(L2Npc)
          kegor.script_value = 2
          kegor.set_walking
          kegor.target = pc
          kegor.set_intention(AI::FOLLOW, pc)
          broadcast_npc_say(kegor, Say2::NPC_ALL, NpcString::I_CAN_FINALLY_TAKE_A_BREATHER_BY_THE_WAY_WHO_ARE_YOU_HMM_I_THINK_I_KNOW_WHO_SENT_YOU)
        end
      end
      InstanceManager.get_instance(world.instance_id).not_nil!.duration = 3000
    else
      # [automatically added else]
    end


    super
  end

  def on_first_talk(npc, pc)
    if qs = pc.get_quest_state(Q10284_AcquisitionOfDivineSword.simple_name)
      if qs.memo_state?(2)
        return npc.script_value?(0) ? "18846.html" : "18846-01.html"
      elsif qs.memo_state?(3)
        world = InstanceManager.get_player_world(pc).not_nil!
        world.remove_allowed(pc.l2id)
        pc.instance_id = 0
        pc.tele_to_location(EXIT_LOC, 0)
        give_adena(pc, 296425, true)
        add_exp_and_sp(pc, 921805, 82230)
        qs.exit_quest(false, true)
        return "18846-03.html"
      end
    end

    super
  end

  def on_kill(npc, pc, is_summon)
    world = InstanceManager.get_world(npc.instance_id).as(MMWorld)

    if npc.id == KEGOR
      broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::HOW_COULD_I_FALL_IN_A_PLACE_LIKE_THIS)
      InstanceManager.get_instance(world.instance_id).not_nil!.duration = 1000
    else
      if npc.script_value?(1)
        world.count += 1
      end

      if world.count >= 5
        qs = pc.get_quest_state(Q10284_AcquisitionOfDivineSword.simple_name)
        if qs && qs.memo_state?(2)
          cancel_quest_timer("BUFF", npc, pc)
          qs.memo_state = 3
          qs.set_cond(6, true)
          start_quest_timer("FINISH", 3000, npc, pc)
        end
      end
    end

    super
  end

  def on_talk(npc, talker)
    case npc.id
    when TARUN, KRUN
      qs = talker.get_quest_state(Q10284_AcquisitionOfDivineSword.simple_name)
      if qs && qs.memo_state?(2)
        unless has_quest_items?(talker, COLD_RESISTANCE_POTION)
          give_items(talker, COLD_RESISTANCE_POTION, 1)
        end
        qs.set_cond(4, true)
        enter_instance(talker, MMWorld.new, "MithrilMine.xml", TEMPLATE_ID)
      end
    when KEGOR
      qs = talker.get_quest_state(Q10284_AcquisitionOfDivineSword.simple_name)
      if qs && qs.memo_state?(2)
        if has_quest_items?(talker, COLD_RESISTANCE_POTION)
          if npc.script_value?(0)
            take_items(talker, COLD_RESISTANCE_POTION, -1)
            qs.set_cond(5, true)
            npc.script_value = 1
            start_quest_timer("TIMER", 3000, npc, talker)
            start_quest_timer("BUFF", 3500, npc, talker)
            return "18846-02.html"
          end
        end
      end
    else
      # [automatically added else]
    end


    super
  end

  def on_enter_instance(pc, world, first_entrance)
    if first_entrance
      world.add_allowed(pc.l2id)
    end

    teleport_player(pc, START_LOC, world.instance_id, false)
  end
end
