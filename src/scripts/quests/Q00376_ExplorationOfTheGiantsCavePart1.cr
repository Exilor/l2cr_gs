class Quests::Q00376_ExplorationOfTheGiantsCavePart1 < Quest
  # NPC
  private SOBLING = 31147
  # Items
  private ANCIENT_PARCHMENT = 14841
  private BOOK1 = 14836
  private BOOK2 = 14837
  private BOOK3 = 14838
  private BOOK4 = 14839
  private BOOK5 = 14840
  # Mobs
  private  MOBS = {
    22670 => 0.314, # const_lord
    22671 => 0.302, # const_gaurdian
    22672 => 0.300, # const_seer
    22673 => 0.258, # hirokai
    22674 => 0.248, # imagro
    22675 => 0.264, # palite
    22676 => 0.258, # hamrit
    22677 => 0.266  # kranout
  }

  def initialize
    super(376, self.class.simple_name, "Exploration of the Giants' Cave - Part 1")

    add_start_npc(SOBLING)
    add_talk_id(SOBLING)
    add_kill_id(MOBS.keys)
    register_quest_items(ANCIENT_PARCHMENT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31147-02.htm"
      qs.start_quest
      html = event
    when "31147-04.html", "31147-cont.html"
      html = event
    when "31147-quit.html"
      qs.exit_quest(true, true)
      html = event
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if qs = get_random_party_member_state(pc, -1, 3, npc)
      give_item_randomly(qs.player, npc, ANCIENT_PARCHMENT, 1, 0, MOBS[npc.id], true)
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= 79 ? "31147-01.htm" : "31147-00.html"
    elsif qs.started?
      if has_quest_items?(pc, BOOK1, BOOK2, BOOK3, BOOK4, BOOK5)
        html = "31147-03.html"
      else
        html = "31147-02a.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
