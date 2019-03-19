class Quests::Q00377_ExplorationOfTheGiantsCavePart2 < Quest
  # NPC
  private SOBLING = 31147
  # Items
  private TITAN_ANCIENT_BOOK = 14847
  private BOOK1 = 14842
  private BOOK2 = 14843
  private BOOK3 = 14844
  private BOOK4 = 14845
  private BOOK5 = 14846
  # Mobs
  private MOBS1 = {
    22660 => 366, # lesser_giant_re
    22661 => 424, # lesser_giant_soldier_re
    22662 => 304, # lesser_giant_shooter_re
    22663 => 304, # lesser_giant_scout_re
    22664 => 354, # lesser_giant_mage_re
    22665 => 324  # lesser_giant_elder_re
  }
  private MOBS2 = {
    22666 => 0.276, # barif_re
    22667 => 0.284, # barif_pet_re
    22668 => 0.240, # gamlin_re
    22669 => 0.240  # leogul_re
  }

  def initialize
    super(377, self.class.simple_name, "Exploration of the Giants' Cave - Part 2")

    add_start_npc(SOBLING)
    add_talk_id(SOBLING)
    add_kill_id(MOBS1.keys)
    add_kill_id(MOBS2.keys)
    register_quest_items(TITAN_ANCIENT_BOOK)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31147-02.htm"
      qs.start_quest
      event
    when "31147-04.html", "31147-cont.html"
      event
    when "31147-quit.html"
      qs.exit_quest(true, true)
      event
    end
  end

  def on_kill(npc, pc, is_summon)
    if qs = get_random_party_member_state(pc, -1, 3, npc)
      npc_id = npc.id
      if tmp = MOBS1[npc_id]?
        item_count = rand(1000) < tmp ? 3 : 2
        give_item_randomly(qs.player, npc, TITAN_ANCIENT_BOOK, item_count, 0, 1.0, true)
      else
        give_item_randomly(qs.player, npc, TITAN_ANCIENT_BOOK, 1, 0, MOBS2[npc_id], true)
      end
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
