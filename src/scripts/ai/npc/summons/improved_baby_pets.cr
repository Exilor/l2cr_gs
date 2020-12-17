class Scripts::ImprovedBabyPets < AbstractNpcAI
  # NPCs
  private IMPROVED_BABY_PETS = {
    16034, # Improved Baby Buffalo
    16035, # Improved Baby Kookaburra
    16036  # Improved Baby Cougar
  }

  # Skill
  private BUFF_CONTROL = 5771

  def initialize
    super(self.class.simple_name, "ai/npc/Summons/Pets")
    add_summon_spawn_id(IMPROVED_BABY_PETS)
  end

  def on_adv_event(event, npc, pc)
    return super unless pc

    pet = pc.summon
    if pet.nil?
      cancel_quest_timer("CAST", nil, pc)
    elsif event == "CAST" && pet.alive? && !pet.hungry? && !pet.casting_now?
      if pc.in_combat?
        hp_per = pc.hp_percent
        heal_step = ((pet.level / 5) - 11).to_i
        heal_type = pet.template.parameters.get_i32("heal_type", 1)

        case heal_type
        when 0
          if hp_per < 30
            cast_heal_skill(pet, heal_step.clamp(0, 3), 2)
          elsif pc.mp_percent < 60
            cast_heal_skill(pet, heal_step.clamp(0, 3), 1)
          end
        when 1
          if hp_per >= 30 && hp_per < 70
            cast_heal_skill(pet, heal_step.clamp(0, 3), 1)
          elsif hp_per < 30
            cast_heal_skill(pet, heal_step.clamp(0, 3), 2)
          end
        end
      end

      unless pet.casting_now? || pet.affected_by_skill?(BUFF_CONTROL)
        buff_step = ((pet.level / 5) - 11).to_i.clamp(0, 3)
        1.upto(2 * (1 + buff_step)) do |i|
          break if cast_buff_skill(pet, buff_step, i)
        end
      end
    end

    super
  end

  @[Register(event: ON_PLAYER_LOGOUT, register: GLOBAL)]
  def on_player_logout(event : OnPlayerLogout)
    cancel_quest_timer("CAST", nil, event.active_char)
  end

  def on_summon_spawn(pet)
    start_quest_timer("CAST", 1500, nil, pet.owner, true)
  end

  private def cast_buff_skill(pet, step_n, buff_n)
    owner = pet.owner
    if owner.nil? || owner.dead? || owner.invul?
      return false
    end

    if skill = pet.template.get_skill_holder("step#{step_n}_buff0#{buff_n}").try &.skill
      parameters = pet.template.parameters
      merged_skill = pet.template.get_skill_holder("step#{step_n}_merged_buff0#{buff_n}").try &.skill
      target_type = parameters.get_i32("step#{step_n}_buff_target0#{buff_n}", 0)
      unless has_abnormal?(owner, skill.abnormal_type)
        total_mp = pet.stat.get_mp_consume1(skill) + pet.stat.get_mp_consume2(skill)
        if pet.current_mp < total_mp
          return false
        end

        if pet.check_do_cast_conditions(skill)
          if merged_skill
            if has_abnormal?(owner, merged_skill.abnormal_type)
              return false
            end
          end

          if target_type >= 0 && target_type <= 2
            pet.target = target_type == 1 ? pet : owner
            pet.use_magic(skill, false, false)
            sm = SystemMessage.pet_uses_s1
            sm.add_skill_name(skill)
            pet.send_packet(sm)

            return true
          end
        end
      end
    end

    false
  end

  private def cast_heal_skill(pet, step_n, heal_num)
    owner = pet.owner
    parameters = pet.template.parameters
    skill = pet.template.get_skill_holder("step#{step_n}_heal0#{heal_num}").try &.skill
    target_type = parameters.get_i32("step #{step_n}_heal_target0#{heal_num}", 0)

    if skill && owner.alive?
      total_mp = pet.stat.get_mp_consume1(skill) + pet.stat.get_mp_consume2(skill)
      if pet.current_mp < total_mp
        return false
      end

      if pet.check_do_cast_conditions(skill)
        unless has_abnormal?(owner, skill.abnormal_type)
          if target_type.between?(0, 2)
            pet.target = target_type == 1 ? pet : owner
            pet.use_magic(skill, false, false)
            sm = SystemMessage.pet_uses_s1
            sm.add_skill_name(skill)
            pet.send_packet(sm)
          end
        end
      end
    end
  end

  private def has_abnormal?(pc, type)
    pc.effect_list.get_buff_info_by_abnormal_type(type)
  end
end
