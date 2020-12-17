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
    return super unless pc && pc.alive? && event == "HEAL"

    if pet = pc.summon.as?(L2PetInstance)
      if pet.alive? && !pet.hungry?
        case pc.hp_percent
        when ..15
          cast_heal_skill(pet, SkillData[GREATER_HEAL_TRICK, get_heal_level(pet)])
        when ..80
          cast_heal_skill(pet, SkillData[HEAL_TRICK, get_heal_level(pet)])
        end
      end
    else
      cancel_quest_timer("HEAL", nil, pc)
    end

    super
  end

  @[Register(event: ON_PLAYER_LOGOUT, register: GLOBAL)]
  def on_player_logout(event : OnPlayerLogout)
    cancel_quest_timer("HEAL", nil, event.active_char)
  end

  def on_summon_spawn(pet)
    start_quest_timer("HEAL", 1000, nil, pet.owner, true)
  end

  private def cast_heal_skill(pet, skill)
    total_mp = pet.stat.get_mp_consume1(skill) + pet.stat.get_mp_consume2(skill)
    if pet.current_mp < total_mp
      return false
    end

    if pet.check_do_cast_conditions(skill)
      pet.target = pet.owner
      pet.use_magic(skill, false, false)
      sm = SystemMessage.pet_uses_s1
      sm.add_skill_name(skill)
      pet.send_packet(sm)
    end
  end

  private def get_heal_level(pet)
    lvl = pet.level
    (lvl < 70 ? (lvl // 10) : (7 &+ ((lvl &- 70) // 5))).clamp(1, 12)
  end
end
