class Scripts::Maguen < AbstractNpcAI
  # NPC
  private MAGUEN = 18839 # Wild Maguen
  private ELITES = {
    22750, # Elite Bgurent (Bistakon)
    22751, # Elite Brakian (Bistakon)
    22752, # Elite Groikan (Bistakon)
    22753, # Elite Treykan (Bistakon)
    22757, # Elite Turtlelian (Reptilikon)
    22758, # Elite Krajian (Reptilikon)
    22759, # Elite Tardyon (Reptilikon)
    22763, # Elite Kanibi (Kokracon)
    22764, # Elite Kiriona (Kokracon)
    22765  # Elite Kaiona (Kokracon)
  }
  # Item
  private MAGUEN_PET = 15488 # Maguen Pet Collar
  private ELITE_MAGUEN_PET = 15489 # Elite Maguen Pet Collar
  # Skills
  private MACHINE = SkillHolder.new(9060, 1) # Maguen Machine
  private B_BUFF_1 = SkillHolder.new(6343, 1) # Maguen Plasma - Power
  private B_BUFF_2 = SkillHolder.new(6343, 2) # Maguen Plasma - Power
  private C_BUFF_1 = SkillHolder.new(6365, 1) # Maguen Plasma - Speed
  private C_BUFF_2 = SkillHolder.new(6365, 2) # Maguen Plasma - Speed
  private R_BUFF_1 = SkillHolder.new(6366, 1) # Maguen Plasma - Critical
  private R_BUFF_2 = SkillHolder.new(6366, 2) # Maguen Plasma - Critical
  private B_PLASMA1 = SkillHolder.new(6367, 1) # Maguen Plasma - Bistakon
  private B_PLASMA2 = SkillHolder.new(6367, 2) # Maguen Plasma - Bistakon
  private B_PLASMA3 = SkillHolder.new(6367, 3) # Maguen Plasma - Bistakon
  private C_PLASMA1 = SkillHolder.new(6368, 1) # Maguen Plasma - Cokrakon
  private C_PLASMA2 = SkillHolder.new(6368, 2) # Maguen Plasma - Cokrakon
  private C_PLASMA3 = SkillHolder.new(6368, 3) # Maguen Plasma - Cokrakon
  private R_PLASMA1 = SkillHolder.new(6369, 1) # Maguen Plasma - Reptilikon
  private R_PLASMA2 = SkillHolder.new(6369, 2) # Maguen Plasma - Reptilikon
  private R_PLASMA3 = SkillHolder.new(6369, 3) # Maguen Plasma - Reptilikon

  def initialize
    super(self.class.simple_name, "gracia/AI")

    add_kill_id(ELITES)
    add_skill_see_id(MAGUEN)
    add_spell_finished_id(MAGUEN)
  end

  def on_adv_event(event, npc, pc)
    return unless npc && pc

    case event
    when "SPAWN_MAGUEN"
       maguen = add_spawn(MAGUEN, npc.location, true, 60000, true)
      maguen.variables["SUMMON_PLAYER"] = pc
      maguen.title = pc.name
      maguen.running = true
      maguen.set_intention(AI::FOLLOW, pc)
      maguen.broadcast_status_update
      show_on_screen_msg(pc, NpcString::MAGUEN_APPEARANCE, 2, 4000)
      start_quest_timer("DIST_CHECK_TIMER", 1000, maguen, pc)
    when "DIST_CHECK_TIMER"
      if npc.calculate_distance(pc, true, false) < 100 && npc.variables.get_i32("IS_NEAR_PLAYER") == 0
        npc.variables["IS_NEAR_PLAYER"] = 1
        start_quest_timer("FIRST_TIMER", 4000, npc, pc)
      else
        start_quest_timer("DIST_CHECK_TIMER", 1000, npc, pc)
      end
    when "FIRST_TIMER"
      npc.ai.stop_follow
      random_effect = rand(1..3)
      npc.display_effect = random_effect
      npc.variables["NPC_EFFECT"] = random_effect
      start_quest_timer("SECOND_TIMER", 5000 + rand(300), npc, pc)
      npc.broadcast_social_action(rand(1..3))
    when "SECOND_TIMER"
      random_effect = rand(1..3)
      npc.display_effect = 4
      npc.display_effect = random_effect
      npc.variables["NPC_EFFECT"] = random_effect
      start_quest_timer("THIRD_TIMER", 4600 + rand(600), npc, pc)
      npc.broadcast_social_action(rand(1..3))
    when "THIRD_TIMER"
      random_effect = rand(1..3)
      npc.display_effect = 4
      npc.display_effect = random_effect
      npc.variables["NPC_EFFECT"] = random_effect
      start_quest_timer("FORTH_TIMER", 4200 + rand(900), npc, pc)
      npc.broadcast_social_action(rand(1..3))
    when "FORTH_TIMER"
      npc.variables["NPC_EFFECT"] = 0
      npc.display_effect = 4
      start_quest_timer("END_TIMER", 500, npc, pc)
      npc.broadcast_social_action(rand(1..3))
    when "END_TIMER"
      if npc.variables.get_i32("TEST_MAGUEN") == 1
        pc.effect_list.stop_skill_effects(true, B_PLASMA1.skill.abnormal_type)
        pc.effect_list.stop_skill_effects(true, C_PLASMA1.skill.abnormal_type)
        pc.effect_list.stop_skill_effects(true, R_PLASMA1.skill.abnormal_type)
        nemo_ai.notify_event("DECREASE_COUNT", npc, pc)
      end
      npc.do_die(nil)
    end

    super
  end

  def on_spell_finished(npc, pc, skill)
    elist = pc.effect_list
    b_info = elist.get_buff_info_by_abnormal_type(B_PLASMA1.skill.abnormal_type)
    c_info = elist.get_buff_info_by_abnormal_type(C_PLASMA1.skill.abnormal_type)
    r_info = elist.get_buff_info_by_abnormal_type(R_PLASMA1.skill.abnormal_type)

    b = b_info ? b_info.skill.abnormal_lvl : 0
    c = c_info ? c_info.skill.abnormal_lvl : 0
    r = r_info ? r_info.skill.abnormal_lvl : 0

    if b == 3 && c == 0 && r == 0
      show_on_screen_msg(pc, NpcString::ENOUGH_MAGUEN_PLASMA_BISTAKON_HAVE_GATHERED, 2, 4000)
      elist.stop_skill_effects(true, B_PLASMA1.skill.abnormal_type)
      npc.target = pc
      npc.do_cast(rand(100) < 70 ? B_BUFF_1 : B_BUFF_2)
      maguen_pet_chance(pc)
      start_quest_timer("END_TIMER", 3000, npc, pc)
    elsif b == 0 && c == 3 && r == 0
      show_on_screen_msg(pc, NpcString::ENOUGH_MAGUEN_PLASMA_COKRAKON_HAVE_GATHERED, 2, 4000)
      elist.stop_skill_effects(true, C_PLASMA1.skill.abnormal_type)
      npc.target = pc
      npc.do_cast(rand(100) < 70 ? C_BUFF_1 : C_BUFF_2)
      maguen_pet_chance(pc)
      start_quest_timer("END_TIMER", 3000, npc, pc)
    elsif b == 0 && c == 0 && r == 3
      show_on_screen_msg(pc, NpcString::ENOUGH_MAGUEN_PLASMA_LEPTILIKON_HAVE_GATHERED, 2, 4000)
      elist.stop_skill_effects(true, R_PLASMA1.skill.abnormal_type)
      npc.target = pc
      npc.do_cast(rand(100) < 70 ? R_BUFF_1 : R_BUFF_2)
      maguen_pet_chance(pc)
      start_quest_timer("END_TIMER", 3000, npc, pc)
    elsif b + c + r == 3
      if b == 1 && c == 1 && r == 1
        elist.stop_skill_effects(true, B_PLASMA1.skill.abnormal_type)
        elist.stop_skill_effects(true, C_PLASMA1.skill.abnormal_type)
        elist.stop_skill_effects(true, R_PLASMA1.skill.abnormal_type)
        show_on_screen_msg(pc, NpcString::THE_PLASMAS_HAVE_FILLED_THE_AEROSCOPE_AND_ARE_HARMONIZED, 2, 4000)

        case rand(3)
        when 0
          skill_to_cast = rand(100) < 70 ? B_BUFF_1 : B_BUFF_2
        when 1
          skill_to_cast = rand(100) < 70 ? C_BUFF_1 : C_BUFF_2
        when 2
          skill_to_cast = rand(100) < 70 ? R_BUFF_1 : R_BUFF_2
        end

        if skill_to_cast
          npc.target = pc
          npc.do_cast(skill_to_cast)
        end
        maguen_pet_chance(pc)
        start_quest_timer("END_TIMER", 3000, npc, pc)
      else
        show_on_screen_msg(pc, NpcString::THE_PLASMAS_HAVE_FILLED_THE_AEROSCOPE_BUT_THEY_ARE_RAMMING_INTO_EACH_OTHER_EXPLODING_AND_DYING, 2, 4000)
        elist.stop_skill_effects(true, B_PLASMA1.skill.abnormal_type)
        elist.stop_skill_effects(true, C_PLASMA1.skill.abnormal_type)
        elist.stop_skill_effects(true, R_PLASMA1.skill.abnormal_type)
      end
    else
      start_quest_timer("END_TIMER", 1000, npc, pc)
    end
    npc.display_effect = 4

    super
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    if skill == MACHINE.skill && caster == npc.variables.get_object("SUMMON_PLAYER", L2PcInstance?)
      if npc.variables.get_i32("NPC_EFFECT") != 0 && npc.variables.get_i32("BLOCKED_SKILLSEE") == 0
        i1_info = caster.effect_list.get_buff_info_by_abnormal_type(B_PLASMA1.skill.abnormal_type)
        i2_info = caster.effect_list.get_buff_info_by_abnormal_type(C_PLASMA1.skill.abnormal_type)
        i3_info = caster.effect_list.get_buff_info_by_abnormal_type(R_PLASMA1.skill.abnormal_type)

        i1 = i1_info ? i1_info.skill.abnormal_lvl : 0
        i2 = i2_info ? i2_info.skill.abnormal_lvl : 0
        i3 = i3_info ? i3_info.skill.abnormal_lvl : 0

        caster.effect_list.stop_skill_effects(true, B_PLASMA1.skill.abnormal_type)
        caster.effect_list.stop_skill_effects(true, C_PLASMA1.skill.abnormal_type)
        caster.effect_list.stop_skill_effects(true, R_PLASMA1.skill.abnormal_type)
        cancel_quest_timer("FIRST_TIMER", npc, caster)
        cancel_quest_timer("SECOND_TIMER", npc, caster)
        cancel_quest_timer("THIRD_TIMER", npc, caster)
        cancel_quest_timer("FORTH_TIMER", npc, caster)
        npc.variables["BLOCKED_SKILLSEE"] = 1

        case npc.variables.get_i32("NPC_EFFECT")
        when 1
          case i1
          when 0
            skill_to_cast = B_PLASMA1
          when 1
            skill_to_cast = B_PLASMA2
          when 2
            skill_to_cast = B_PLASMA3
          end
        when 2
          case i2
          when 0
            skill_to_cast = C_PLASMA1
          when 1
            skill_to_cast = C_PLASMA2
          when 2
            skill_to_cast = C_PLASMA3
          end
        when 3
          case i3
          when 0
            skill_to_cast = R_PLASMA1
          when 1
            skill_to_cast = R_PLASMA2
          when 2
            skill_to_cast = R_PLASMA3
          end
        end

        if skill_to_cast
          npc.target = caster
          npc.do_cast(skill_to_cast)
        end
      end
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    if killer.in_party?
      party_member = get_random_party_member(killer).not_nil!
      i0 = 10 + (10 * killer.party.size)

      if rand(1000) < i0 && npc.calculate_distance(killer, true, false) < 2000
        if npc.calculate_distance(party_member, true, false) < 2000
          notify_event("SPAWN_MAGUEN", npc, party_member)
        end
      end
    end

    super
  end

  private def maguen_pet_chance(pc)
    chance1 = rand(10000)
    chance2 = rand(20)
    if chance1 == 0 && chance2 != 0
      give_items(pc, MAGUEN_PET, 1)
    elsif chance1 == 0 && chance2 == 0
      give_items(pc, ELITE_MAGUEN_PET, 1)
    end
  end

  private def nemo_ai
    QuestManager.get_quest(Nemo.simple_name).not_nil!
  end
end
