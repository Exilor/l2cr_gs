class NpcAI::ImprovedBabyPets < AbstractNpcAI
  # NPCs
  private IMPROVED_BABY_PETS = {
    16034, # Improved Baby Buffalo
    16035, # Improved Baby Kookaburra
    16036, # Improved Baby Cougar
  }

  # Skill
  private BUFF_CONTROL = 5771

  def initialize
    super(self.class.simple_name, "ai/npc/Summons/Pets")
    add_summon_spawn_id(IMPROVED_BABY_PETS)
  end

  def on_adv_event(event, npc, player)
    debug "#on_adv_event: #{event}, #{npc}, #{player}"
    if player
      pet = player.summon
      if pet.nil?
        cancel_quest_timer("CAST_BUFF", nil, player)
        cancel_quest_timer("CAST_HEAL", nil, player)
      elsif event == "CAST_HEAL" && player.in_combat? && !pet.hungry?
        hp_per = (player.current_hp / player.max_hp) * 100
        mp_per = (player.current_mp / player.max_mp) * 100
        heal_step = ((pet.level / 5) - 11).to_i
        heal_type = pet.template.parameters.get_i32("heal_type", 0)

        case heal_type
        when 0
          if hp_per < 30
            cast_heal_skill(pet, heal_step.clamp(0, 3), 2)
          elsif mp_per < 60
            cast_heal_skill(pet, heal_step.clamp(0, 3), 1)
          end
        when 1
          if hp_per >= 30 && hp_per < 70
            cast_heal_skill(pet, heal_step.clamp(0, 3), 1)
          elsif hp_per < 30
            cast_heal_skill(pet, heal_step.clamp(0, 3), 2)
          end
        end
      elsif event == "CAST_BUFF" && !pet.affected_by_skill?(BUFF_CONTROL)
        unless pet.hungry?
          buff_step = (((pet.level / 5) - 11).clamp(0, 3)).to_i
          1.upto(2 * (1 + buff_step)) do |i|
            cast_buff_skill(pet, buff_step, i)
          end
        end
      end
    end

    super
  end

  @[Register(event: ON_PLAYER_LOGOUT, register: GLOBAL)]
  def on_player_logout(event : OnPlayerLogout)
    cancel_quest_timer("CAST_BUFF", nil, event.active_char)
    cancel_quest_timer("CAST_HEAL", nil, event.active_char)
  end

  def on_summon_spawn(summon)
    start_quest_timer("CAST_BUFF", 10000, nil, summon.owner, true)
    start_quest_timer("CAST_HEAL", 3000, nil, summon.owner, true)
  end

  private def cast_buff_skill(summon, step_n, buff_n)
    owner = summon.owner
    if owner.nil? || owner.dead? || owner.invul?
      return false
    end

    parameters = summon.template.parameters
    skill = parameters.get_object("step#{step_n}_buff0#{buff_n}", SkillHolder?)

    # unless skill
    #   warn "Skill not found."
    # end

    if skill
      merged_skill = parameters.get_object("step#{step_n}_merged_buff0#{buff_n}", SkillHolder?)
      target_type = parameters.get_i32("step#{step_n}_buff_target0#{buff_n}", 0)
      if !has_abnormal?(owner, skill.skill.abnormal_type) && summon.check_do_cast_conditions(skill.skill)
        if merged_skill && has_abnormal?(owner, merged_skill.skill.abnormal_type)
          return false
        end

        prev_follow_status = summon.follow_status

        if !prev_follow_status && !summon.inside_radius?(owner, skill.skill.cast_range, true, true)
          return false
        end

        if target_type >= 0 && target_type <= 2
          summon.target = target_type == 1 ? summon : owner
          summon.do_cast(skill.skill)
          sm = SystemMessage.pet_uses_s1
          sm.add_skill_name(skill.skill)
          summon.send_packet(sm)

          if prev_follow_status != summon.follow_status
            summon.follow_status = prev_follow_status
          end

          return true
        end
      end
    end

    false
  end

  private def cast_heal_skill(summon, step_n, heal_num)
    owner = summon.owner?
    parameters = summon.template.parameters
    skill = parameters.get_object("step#{step_n}_heal0#{heal_num}", SkillHolder?)
    target_type = parameters.get_i32("step #{step_n}_heal_target0#{heal_num}", 0)

    if skill && owner && owner.alive? && summon.check_do_cast_conditions(skill.skill)
      prev_follow_status = summon.follow_status

      if !prev_follow_status
        if !summon.inside_radius?(owner, skill.skill.cast_range, true, true)
          return
        end
      end

      unless has_abnormal?(owner, skill.skill.abnormal_type)
        if target_type >= 0 && target_type <= 2
          summon.target = target_type == 1 ? summon : owner
          summon.do_cast(skill.skill)
          sm = SystemMessage.pet_uses_s1
          sm.add_skill_name(skill.skill)
          summon.send_packet(sm)

          if prev_follow_status != summon.follow_status
            summon.follow_status = prev_follow_status
          end
        end
      end
    end
  end

  private def has_abnormal?(player, type)
    player.effect_list.get_buff_info_by_abnormal_type(type)
  end
end
