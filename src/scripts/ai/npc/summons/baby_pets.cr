class Scripts::BabyPets < AbstractNpcAI
  # NPCs
  private BABY_PETS = {
    12780, # Baby Buffalo
    12781, # Baby Kookaburra
    12782  # Baby Cougar
  }

  # Skills
  private HEAL_TRICK = 4717
  private GREATER_HEAL_TRICK = 4718

  def initialize
    super(self.class.simple_name, "ai/npc/Summons/Pets")
    add_summon_spawn_id(BABY_PETS)
  end

  def on_adv_event(event, npc, pc)
    # debug "on_adv_event(#{event}, #{npc}, #{pc})"
    if event == "CAST_HEAL" && pc
      pet = pc.summon.as?(L2PetInstance)

      if pet
        if Rnd.rand(100) <= 25
          sh = SkillHolder.new(HEAL_TRICK, get_heal_level(pet))
          cast_heal_skill(pet, sh, 80)
        end

        if Rnd.rand(100) <= 75
          sh = SkillHolder.new(GREATER_HEAL_TRICK, get_heal_level(pet))
          cast_heal_skill(pet, sh, 15)
        end
      else
        cancel_quest_timer("CAST_HEAL", nil, pc)
      end
    end

    super
  end

  @[Register(event: ON_PLAYER_LOGOUT, register: GLOBAL)]
  def on_player_logout(event : OnPlayerLogout)
    cancel_quest_timer("CAST_HEAL", nil, event.active_char)
  end

  def on_summon_spawn(summon)
    start_quest_timer("CAST_HEAL", 1000, nil, summon.owner, true)
  end

  private def cast_heal_skill(summon, skill, max_hp_per)
    # debug "#{summon} casting #{skill.skill}."
    owner = summon.owner
    if owner.alive? && !summon.hungry?
      if (owner.current_hp / owner.max_hp) * 100 < max_hp_per
        if summon.check_do_cast_conditions(skill.skill)
          prev_follow_status = summon.follow_status

          unless prev_follow_status
            unless summon.inside_radius?(owner, skill.skill.cast_range, true, true)
              return
            end
          end

          summon.target = owner
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

  private def get_heal_level(summon)
    lvl = summon.level
    (lvl < 70 ? (lvl // 10) : (7 + ((lvl - 70) // 5))).clamp(1, 12)
  end
end
