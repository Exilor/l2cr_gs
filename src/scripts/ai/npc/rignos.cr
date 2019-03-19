class NpcAI::Rignos < AbstractNpcAI
  # NPC
  private RIGNOS = 32349 # Rignos
  # Item
  private STAMP = 10013 # Race Stamp
  private KEY = 9694 # Secret Key
  # Skill
  private TIMER = SkillHolder.new(5239, 5) # Event Timer
  # Misc
  private MIN_LVL = 78

  def initialize
    super(self.class.simple_name, "ai/npc")

    add_start_npc(RIGNOS)
    add_talk_id(RIGNOS)
    add_first_talk_id(RIGNOS)
  end

  def on_adv_event(event, npc, pc)
    case event
    when "32349-03.html"
      return event
    when "startRace"
      npc = npc.not_nil!
      pc = pc.not_nil!
      if npc.script_value?(0)
        npc.script_value = 1
        start_quest_timer("TIME_OUT", 1800000, npc, nil)
        TIMER.skill.apply_effects(pc, pc)
        if summon = pc.summon
          TIMER.skill.apply_effects(summon, summon)
        end

        if has_quest_items?(pc, STAMP)
          take_items(pc, STAMP, -1)
        end
      end
    when "exchange"
      pc = pc.not_nil!
      if get_quest_items_count(pc, STAMP) >= 4
        give_items(pc, KEY, 3)
        take_items(pc, STAMP, -1)
      end
    when "TIME_OUT"
      npc.not_nil!.script_value = 0
    end

    super
  end

  def on_first_talk(npc, pc)
    if npc.script_value?(0) && pc.level
      html = "32349.html"
    else
      html = "32349-02.html"
    end
    if get_quest_items_count(pc, STAMP) >= 4
      html = "32349-01.html"
    end

    html
  end
end
