class Scripts::MuscleBomber < AbstractNpcAI
  # NPC
  private MUSCLE_BOMBER = 25724
  private DRAKOS_ASSASSIN = 22823
  # Skills
  private ENHANCE_LVL_1 = SkillHolder.new(6842, 1)
  private ENHANCE_LVL_2 = SkillHolder.new(6842, 2)
  # Variables
  private HIGH_HP_FLAG = "HIGH_HP_FLAG"
  private MED_HP_FLAG = "MED_HP_FLAG"
  private LIMIT_FLAG = "LIMIT_FLAG"
  # Timers
  private TIMER_SUMMON = "TIMER_SUMMON"
  private TIMER_LIMIT = "TIMER_LIMIT"
  # Misc
  private MAX_CHASE_DIST = 2500
  private HIGH_HP_PERCENTAGE = 80
  private MED_HP_PERCENTAGE = 50

  def initialize
    super(self.class.simple_name, "ai/individual")
    add_attack_id(MUSCLE_BOMBER)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if Util.calculate_distance(npc, npc.spawn, false, false) > MAX_CHASE_DIST
      npc.tele_to_location(*npc.spawn.xyz)
    end

    if npc.hp_percent < HIGH_HP_PERCENTAGE
      unless npc.variables.get_bool(HIGH_HP_FLAG, false)
        npc.variables[HIGH_HP_FLAG] = true
        add_skill_cast_desire(npc, npc, ENHANCE_LVL_1, 999999999000000000)
      end
    end

    if npc.hp_percent < MED_HP_PERCENTAGE
      unless npc.variables.get_bool(MED_HP_FLAG, false)
        npc.variables[MED_HP_FLAG] = true
        add_skill_cast_desire(npc, npc, ENHANCE_LVL_2, 999999999000000000)
        start_quest_timer(TIMER_SUMMON, 60_000, npc, attacker)
        start_quest_timer(TIMER_LIMIT, 300_000, npc, attacker)
      end
    end

    super
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!

    case event
    when TIMER_LIMIT
      npc.variables[LIMIT_FLAG] = true
    when TIMER_SUMMON
      if npc.alive? && !npc.variables.get_bool(LIMIT_FLAG, false)
        if pc
          add_attack_desire(add_spawn(DRAKOS_ASSASSIN, npc.x + rand(100), npc.y + rand(10), npc.z, npc.heading, false, 0), pc)
          add_attack_desire(add_spawn(DRAKOS_ASSASSIN, npc.x + rand(100), npc.y + rand(10), npc.z, npc.heading, false, 0), pc)
        end
        start_quest_timer(TIMER_SUMMON, 60_000, npc, pc)
      end
    end

    super
  end
end
