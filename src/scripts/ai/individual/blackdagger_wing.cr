class Scripts::BlackdaggerWing < AbstractNpcAI
  # NPCs
  private BLACKDAGGER_WING = 25721
  # Skills
  private POWER_STRIKE = SkillHolder.new(6833)
  private RANGE_MAGIC_ATTACK = SkillHolder.new(6834)
  # Variables
  private MID_HP_FLAG = "MID_HP_FLAG"
  private POWER_STRIKE_CAST_COUNT = "POWER_STRIKE_CAST_COUNT"
  # Timers
  private DAMAGE_TIMER = "DAMAGE_TIMER"
  # Misc
  private MAX_CHASE_DIST = 2500
  private MID_HP_PERCENTAGE = 50

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_attack_id(BLACKDAGGER_WING)
    add_see_creature_id(BLACKDAGGER_WING)
    add_spell_finished_id(BLACKDAGGER_WING)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if Util.calculate_distance(npc, npc.spawn, false, false) > MAX_CHASE_DIST
      npc.tele_to_location(*npc.spawn.xyz)
    end

    if npc.hp_percent < MID_HP_PERCENTAGE
      unless npc.variables.get_bool(MID_HP_FLAG, false)
        npc.variables[MID_HP_FLAG] = true
        start_quest_timer(DAMAGE_TIMER, 10_000, npc, attacker)
      end
    end

    super
  end

  def on_see_creature(npc, creature, is_summon)
    if npc.variables.get_bool(MID_HP_FLAG, false)
      most_hated = npc.as(L2Attackable).most_hated
      if most_hated && most_hated.player? && most_hated != creature
        if Rnd.rand(5) < 1
          add_skill_cast_desire(npc, creature, RANGE_MAGIC_ATTACK, 9999900000000000)
        end
      end
    end

    super
  end

  def on_spell_finished(npc, pc, skill)
    if skill.id == POWER_STRIKE.skill_id
      npc.variables[POWER_STRIKE_CAST_COUNT] = npc.variables.get_i32(POWER_STRIKE_CAST_COUNT) &+ 1
      if npc.variables.get_i32(POWER_STRIKE_CAST_COUNT) > 3
        add_skill_cast_desire(npc, pc, RANGE_MAGIC_ATTACK, 9999900000000000)
        npc.variables[POWER_STRIKE_CAST_COUNT] = 0
      end
    end

    super
  end

  def on_adv_event(event, npc, pc)
    if event == DAMAGE_TIMER
      npc = npc.not_nil!
      pc = pc.not_nil!
      npc.set_intention(AI::ATTACK, pc) # L2J doesn't give the second arg
      start_quest_timer(DAMAGE_TIMER, 30_000, npc, pc)
    end

    super
  end
end
