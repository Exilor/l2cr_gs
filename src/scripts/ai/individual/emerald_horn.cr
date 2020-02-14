class Scripts::EmeraldHorn < AbstractNpcAI
  private EMERALD_HORN = 25718
  # Skills
  private REFLECT_ATTACK = SkillHolder.new(6823, 1)
  private PIERCING_STORM = SkillHolder.new(6824, 1)
  private BLEED_LVL_1 = SkillHolder.new(6825, 1)
  private BLEED_LVL_2 = SkillHolder.new(6825, 2)
  # Variables
  private HIGH_DAMAGE_FLAG = "HIGH_DAMAGE_FLAG"
  private TOTAL_DAMAGE_COUNT = "TOTAL_DAMAGE_COUNT"
  private CAST_FLAG = "CAST_FLAG"
  # Timers
  private DAMAGE_TIMER_15S = "DAMAGE_TIMER_15S"
  # Misc
  private MAX_CHASE_DIST = 2500

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_attack_id(EMERALD_HORN)
    add_spell_finished_id(EMERALD_HORN)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if Util.calculate_distance(npc, npc.spawn, false, false) > MAX_CHASE_DIST
      npc.tele_to_location(*npc.spawn.xyz)
    end

    if npc.affected_by_skill?(REFLECT_ATTACK.skill_id)
      if npc.variables.get_bool(CAST_FLAG, false)
        npc.variables[TOTAL_DAMAGE_COUNT] = npc.variables.get_i32(TOTAL_DAMAGE_COUNT) + damage
      end
    end

    if npc.variables.get_i32(TOTAL_DAMAGE_COUNT) > 5000
      add_skill_cast_desire(npc, attacker, BLEED_LVL_2, 9999000000000000)
      npc.variables[TOTAL_DAMAGE_COUNT] = 0
      npc.variables[CAST_FLAG] = false
      npc.variables[HIGH_DAMAGE_FLAG] = true
    end

    if npc.variables.get_i32(TOTAL_DAMAGE_COUNT) > 10000
      add_skill_cast_desire(npc, attacker, BLEED_LVL_1, 9999000000000000)
      npc.variables[TOTAL_DAMAGE_COUNT] = 0
      npc.variables[CAST_FLAG] = false
      npc.variables[HIGH_DAMAGE_FLAG] = true
    end

    super
  end

  def on_spell_finished(npc, pc, skill)
    if Rnd.rand(5) < 1
      npc.variables[TOTAL_DAMAGE_COUNT] = 0
      npc.variables[CAST_FLAG] = true
      add_skill_cast_desire(npc, npc, REFLECT_ATTACK, 99999000000000000)
      start_quest_timer(DAMAGE_TIMER_15S, 15 * 1000, npc, pc)
    end

    super
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    if event == DAMAGE_TIMER_15S
      unless npc.variables.get_bool(HIGH_DAMAGE_FLAG, false)
        if most_hated = npc.as(L2Attackable).most_hated
          if most_hated.dead?
            npc.as(L2Attackable).stop_hating(most_hated)
          else
            add_skill_cast_desire(npc, most_hated, PIERCING_STORM, 9999000000000000)
          end
        end
      end
      npc.variables[CAST_FLAG] = false
    end

    super
  end
end
