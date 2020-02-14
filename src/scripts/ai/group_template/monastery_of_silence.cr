class Scripts::MonasteryOfSilence < AbstractNpcAI
  # NPCs
  private CAPTAIN   = 18910 # Solina Knight Captain
  private KNIGHT    = 18909 # Solina Knights
  private SCARECROW = 18912 # Scarecrow
  private GUIDE     = 22789 # Guide Solina
  private SEEKER    = 22790 # Seeker Solina
  private SAVIOR    = 22791 # Savior Solina
  private ASCETIC   = 22793 # Ascetic Solina
  private DIVINITY_CLAN = {
    22794, # Divinity Judge
    22795  # Divinity Manager
  }
  # Skills
  private ORDEAL_STRIKE     = SkillHolder.new(6303) # Trial of the Coup
  private LEADER_STRIKE     = SkillHolder.new(6304) # Shock
  private SAVIOR_STRIKE     = SkillHolder.new(6305) # Sacred Gnosis
  private SAVIOR_BLEED      = SkillHolder.new(6306) # Solina Strike
  private LEARNING_MAGIC    = SkillHolder.new(6308) # Opus of the Wave
  private STUDENT_CANCEL    = SkillHolder.new(6310) # Loss of Quest
  private WARRIOR_THRUSTING = SkillHolder.new(6311) # Solina Thrust
  private KNIGHT_BLESS      = SkillHolder.new(6313) # Solina Bless
  # Misc
  private DIVINITY_MSG = {
    NpcString::S1_WHY_WOULD_YOU_CHOOSE_THE_PATH_OF_DARKNESS,
    NpcString::S1_HOW_DARE_YOU_DEFY_THE_WILL_OF_EINHASAD
  }
  private SOLINA_KNIGHTS_MSG = {
    NpcString::PUNISH_ALL_THOSE_WHO_TREAD_FOOTSTEPS_IN_THIS_PLACE,
    NpcString::WE_ARE_THE_SWORD_OF_TRUTH_THE_SWORD_OF_SOLINA,
    NpcString::WE_RAISE_OUR_BLADES_FOR_THE_GLORY_OF_SOLINA
  }

  def initialize
    super(self.class.simple_name, "ai/group_template")

    add_skill_see_id(DIVINITY_CLAN)
    add_attack_id(KNIGHT, CAPTAIN, GUIDE, SEEKER, ASCETIC)
    add_npc_hate_id(GUIDE, SEEKER, SAVIOR, ASCETIC)
    add_aggro_range_enter_id(GUIDE, SEEKER, SAVIOR, ASCETIC)
    add_spawn_id(SCARECROW)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "TRAINING"
      npc = npc.not_nil!
      npc.known_list.each_character(400) do |char|
        if Rnd.rand(100) < 30 && char.is_a?(L2Npc) && char.alive? && !char.in_combat?
          if char.id == CAPTAIN
            if Rnd.rand(100) < 10 && npc.script_value?(0)
              msg = SOLINA_KNIGHTS_MSG.sample
              broadcast_npc_say(char, Say2::NPC_ALL, msg)
              char.script_value = 1
              start_quest_timer("TIMER", 10_000, char, nil)
            end
          elsif char.id == KNIGHT
            char.set_running
            char.as(L2Attackable).add_damage_hate(npc, 0, 100)
            char.set_intention(AI::ATTACK, npc)
          end
        end
      end
    when "DO_CAST"
      if npc && pc && Rnd.rand(100) < 3
        if npc.check_do_cast_conditions(STUDENT_CANCEL.skill)
          npc.target = pc
          npc.do_cast(STUDENT_CANCEL)
        end
        npc.script_value = 0
      end
    when "TIMER"
      if npc
        npc.script_value = 0
      end
    end

    super
  end

  def on_attack(npc, pc, damage, is_summon)
    case npc.id
    when KNIGHT
      if Rnd.rand(100) < 10 && npc.most_hated == pc
        if npc.check_do_cast_conditions(WARRIOR_THRUSTING.skill)
          npc.target = pc
          npc.do_cast(WARRIOR_THRUSTING)
        end
      end
    when CAPTAIN
      if Rnd.rand(100) < 20 && npc.hp_percent < 50
        if npc.script_value?(0)
          if npc.check_do_cast_conditions(KNIGHT_BLESS.skill)
            npc.target = npc
            npc.do_cast(KNIGHT_BLESS)
          end
          npc.script_value = 1
          broadcast_npc_say(npc, Say2::ALL, NpcString::FOR_THE_GLORY_OF_SOLINA)
          add_attack_desire(add_spawn(KNIGHT, npc), pc)
        end
      end
    when GUIDE
      if Rnd.rand(100) < 3 && npc.most_hated == pc
        if npc.check_do_cast_conditions(ORDEAL_STRIKE.skill)
          npc.target = pc
          npc.do_cast(ORDEAL_STRIKE)
        end
      end
    when SEEKER
      if Rnd.rand(100) < 33 && npc.most_hated == pc
        if npc.check_do_cast_conditions(SAVIOR_STRIKE.skill)
          npc.target = npc
          npc.do_cast(SAVIOR_STRIKE)
        end
      end
    when ASCETIC
      if npc.most_hated == pc && npc.script_value?(0)
        npc.script_value = 1
        start_quest_timer("DO_CAST", 20000, npc, pc)
      end
    end

    super
  end

  def on_npc_hate(mob, pc, is_summon)
    !!pc.active_weapon_instance
  end

  def on_aggro_range_enter(npc, pc, is_summon)
    debug { "#on_aggro_range_enter: #{npc}, #{pc}, #{is_summon}" }
    if pc.active_weapon_instance
      skill = nil
      case npc.id
      when GUIDE
        if Rnd.rand(100) < 3
          skill = LEADER_STRIKE
        end
      when SEEKER
        skill = SAVIOR_BLEED
      when SAVIOR
        skill = LEARNING_MAGIC
      when ASCETIC
        if Rnd.rand(100) < 3
          skill = STUDENT_CANCEL
        end

        if npc.script_value?(0)
          npc.script_value = 1
          start_quest_timer("DO_CAST", 20000, npc, pc)
        end
      end


      if skill && npc.check_do_cast_conditions(skill.skill)
        npc.target = pc
        npc.do_cast(skill)
      end

      # unless npc.in_combat? # Doesn't work.
      #   broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::YOU_CANNOT_CARRY_A_WEAPON_WITHOUT_AUTHORIZATION)
      # end

      if npc.attack_by_list.empty?
        broadcast_npc_say(npc, Say2::NPC_ALL, NpcString::YOU_CANNOT_CARRY_A_WEAPON_WITHOUT_AUTHORIZATION)
      end

      add_attack_desire(npc, pc)
    end

    super
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    debug { "#on_skill_see: #{npc}, #{caster}, #{skill}, #{targets}, #{is_summon}" }
    if skill.has_effect_type?(EffectType::AGGRESSION)
      targets.each do |obj|
        if obj == npc
          broadcast_npc_say(npc, Say2::NPC_ALL, DIVINITY_MSG.sample, caster.name)
          add_attack_desire(npc, caster)
          break
        end
      end
    end

    super
  end

  def on_spawn(npc)
    npc.invul = true
    npc.disable_core_ai(true)
    start_quest_timer("TRAINING", 30000, npc, nil, true)

    super
  end
end
