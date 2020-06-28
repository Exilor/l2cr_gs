class Scripts::BleedingFly < AbstractNpcAI
  # NPCs
  private BLEEDING_FLY = 25720
  private PARASITIC_LEECH = 25734
  # Skills
  private SUMMON_PARASITE_LEECH = SkillHolder.new(6832)
  private NPC_ACUMEN_LVL_3 = SkillHolder.new(6915, 3)
  # Variables
  private MID_HP_FLAG = "MID_HP_FLAG"
  private LOW_HP_FLAG = "LOW_HP_FLAG"
  private MID_HP_MINION_COUNT = "MID_HP_MINION_COUNT"
  private LOW_HP_MINION_COUNT = "LOW_HP_MINION_COUNT"
  # Timers
  private TIMER_MID_HP = "TIMER_MID_HP"
  private TIMER_LOW_HP = "TIMER_LOW_HP"
  # Misc
  private MAX_CHASE_DIST = 2500
  private MID_HP_PERCENTAGE = 50
  private MIN_HP_PERCENTAGE = 25

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_attack_id(BLEEDING_FLY)
    add_spawn_id(BLEEDING_FLY)
  end

  def on_spawn(npc)
    npc.variables[MID_HP_MINION_COUNT] = 5
    npc.variables[LOW_HP_MINION_COUNT] = 10

    super
  end

  def on_attack(npc, attacker, damage, is_summon)
    if Util.calculate_distance(npc, npc.spawn, false, false) > MAX_CHASE_DIST
      npc.tele_to_location(*npc.spawn.xyz)
    end

    if npc.hp_percent < MID_HP_PERCENTAGE
      unless npc.variables.get_bool(MID_HP_FLAG, false)
        npc.variables[MID_HP_FLAG] = true
        start_quest_timer(TIMER_MID_HP, 1000, npc, nil)
      end
    end

    if npc.hp_percent < MIN_HP_PERCENTAGE
      unless npc.variables.get_bool(LOW_HP_FLAG, false)
        npc.variables[MID_HP_FLAG] = false
        npc.variables[LOW_HP_FLAG] = true
        start_quest_timer(TIMER_LOW_HP, 1000, npc, nil)
      end
    end

    super
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    if npc.dead?
      return super
    end

    case event
    when TIMER_MID_HP
      if npc.variables.get_i32(MID_HP_MINION_COUNT) > 0
        npc.variables[MID_HP_MINION_COUNT] = npc.variables.get_i32(MID_HP_MINION_COUNT) - 1
        add_skill_cast_desire(npc, npc, SUMMON_PARASITE_LEECH, 9999999999900000)
        add_spawn(PARASITIC_LEECH, npc.x + Rnd.rand(150), npc.y + Rnd.rand(150), npc.z, npc.heading, false, 0)
        add_spawn(PARASITIC_LEECH, npc.x + Rnd.rand(150), npc.y + Rnd.rand(150), npc.z, npc.heading, false, 0)

        if npc.variables.get_bool(MID_HP_FLAG, false)
          start_quest_timer(TIMER_MID_HP, 140000, npc, nil)
        end
      end
    when TIMER_LOW_HP
      if npc.variables.get_i32(LOW_HP_MINION_COUNT) > 0
        npc.variables[LOW_HP_MINION_COUNT] = npc.variables.get_i32(LOW_HP_MINION_COUNT) - 1
        add_skill_cast_desire(npc, npc, SUMMON_PARASITE_LEECH, 9999999999900000)
        add_skill_cast_desire(npc, npc, NPC_ACUMEN_LVL_3, 9999999999900000)
        add_spawn(PARASITIC_LEECH, npc.x + Rnd.rand(150), npc.y + Rnd.rand(150), npc.z, npc.heading, false, 0)
        add_spawn(PARASITIC_LEECH, npc.x + Rnd.rand(150), npc.y + Rnd.rand(150), npc.z, npc.heading, false, 0)

        if npc.variables.get_bool(LOW_HP_FLAG, false)
          start_quest_timer(TIMER_LOW_HP, 80000, npc, nil)
        end
      end
    end


    super
  end
end
