class Scripts::ShadowSummoner < AbstractNpcAI
  # NPCs
  private SHADOW_SUMMONER = 25722
  private DEMONS_BANQUET_1 = 25730
  private DEMONS_BANQUET_2 = 25731
  # Skills
  private SUMMON_SKELETON = SkillHolder.new(6835)
  # Variables
  private LOW_HP_FLAG = "LOW_HP_FLAG"
  private LIMIT_FLAG = "LIMIT_FLAG"
  # Timers
  private SUMMON_TIMER = "SUMMON_TIMER"
  private FEED_TIMER = "FEED_TIMER"
  private LIMIT_TIMER = "LIMIT_TIMER"
  private DELAY_TIMER = "DELAY_TIMER"
  # Misc
  private MAX_CHASE_DIST = 2500
  private MIN_HP_PERCENTAGE = 25

  def initialize
    super(self.class.simple_name, "ai/individual")

    add_attack_id(SHADOW_SUMMONER)
    add_see_creature_id(SHADOW_SUMMONER)
  end

  def on_attack(npc, attacker, damage, is_summon)
    if Util.calculate_distance(npc, npc.spawn, false, false) > MAX_CHASE_DIST
      npc.tele_to_location(*npc.spawn.xyz)
    end

    if npc.hp_percent < MIN_HP_PERCENTAGE
      unless npc.variables.get_bool(LOW_HP_FLAG, false)
        npc.variables[LOW_HP_FLAG] = true
        start_quest_timer(SUMMON_TIMER, 1000, npc, attacker)
        start_quest_timer(FEED_TIMER, 30000, npc, attacker)
        start_quest_timer(LIMIT_TIMER, 600000, npc, attacker)
      end
    end

    super
  end

  def on_see_creature(npc, creature, is_summon)
    unless creature.player?
      if creature.id == DEMONS_BANQUET_2
        npc.as(L2Attackable).clear_aggro_list
        add_attack_desire(npc, creature, 9999999999999999)
      end
    end

    super
  end

  def on_adv_event(event, npc, pc)
    npc = npc.not_nil!
    pc = pc.not_nil!

    if npc.dead?
      return super
    end

    case event
    when SUMMON_TIMER
      unless npc.variables.get_bool(LIMIT_FLAG, false)
        start_quest_timer(DELAY_TIMER, 5000, npc, pc)
        start_quest_timer(SUMMON_TIMER, 30000, npc, pc)
      end
    when FEED_TIMER
      unless npc.variables.get_bool(LIMIT_FLAG, false)
        npc.set_intention(AI::ATTACK, pc)
        start_quest_timer(FEED_TIMER, 30000, npc, pc)
      end
    when LIMIT_TIMER
      npc.variables[LIMIT_FLAG] = true
    when DELAY_TIMER
      add_skill_cast_desire(npc, npc, SUMMON_SKELETON, 9999999999900000)
      id = Rnd.bool ? DEMONS_BANQUET_1 : DEMONS_BANQUET_2
      demons_banquet = add_spawn(id, npc.x + 150, npc.y + 150, npc.z, npc.heading, false, 0)
      add_attack_desire(demons_banquet, pc, 10000)
    else
      # automatically added
    end


    super
  end
end