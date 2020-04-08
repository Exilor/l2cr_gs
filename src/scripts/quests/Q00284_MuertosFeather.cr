class Scripts::Q00284_MuertosFeather < Quest
  # NPC
  private TREVOR = 32166
  # Item
  private MUERTOS_FEATHER = 9748
  # Monsters
  private MOB_DROP_CHANCE = {
    22239 => 0.500, # Muertos Guard
    22240 => 0.533, # Muertos Scout
    22242 => 0.566, # Muertos Warrior
    22243 => 0.600, # Muertos Captain
    22245 => 0.633, # Muertos Lieutenant
    22246 => 0.633  # Muertos Commander
  }
  # Misc
  private MIN_LVL = 11

  def initialize
    super(284, self.class.simple_name, "Muertos Feather")

    add_start_npc(TREVOR)
    add_talk_id(TREVOR)
    add_kill_id(MOB_DROP_CHANCE.keys)
    register_quest_items(MUERTOS_FEATHER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "32166-03.htm"
      qs.start_quest
      html = event
    when "32166-06.html"
      html = event
    when "32166-08.html"
      if has_quest_items?(pc, MUERTOS_FEATHER)
        give_adena(pc, get_quest_items_count(pc, MUERTOS_FEATHER) * 45, true)
        take_items(pc, MUERTOS_FEATHER, -1)
        html = event
      else
        html = "32166-07.html"
      end
    when "32166-09.html"
      qs.exit_quest(true, true)
      html = event
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, 1, 3, npc)
      give_item_randomly(qs.player, npc, MUERTOS_FEATHER, 1, 0, MOB_DROP_CHANCE[npc.id], true)
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    if qs.created?
      pc.level >= MIN_LVL ? "32166-01.htm" : "32166-02.htm"
    elsif qs.started?
      has_quest_items?(pc, MUERTOS_FEATHER) ? "32166-05.html" : "32166-04.html"
    else
      get_no_quest_msg(pc)
    end
  end
end