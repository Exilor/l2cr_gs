class Scripts::Q00629_CleanUpTheSwampOfScreams < Quest
  # NPC
  private PIERCE = 31553
  # Items
  private TALON_OF_STAKATO = 7250
  private GOLDEN_RAM_COIN = 7251
  # Misc
  private REQUIRED_TALON_COUNT = 100
  private MIN_LVL = 66
  # Mobs
  private MOBS_DROP_CHANCES = {
    21508 => 0.599, # splinter_stakato
    21509 => 0.524, # splinter_stakato_worker
    21510 => 0.640, # splinter_stakato_soldier
    21511 => 0.830, # splinter_stakato_drone
    21512 => 0.970, # splinter_stakato_drone_a
    21513 => 0.682, # needle_stakato
    21514 => 0.595, # needle_stakato_worker
    21515 => 0.727, # needle_stakato_soldier
    21516 => 0.879, # needle_stakato_drone
    21517 => 0.999 # needle_stakato_drone_a
  }

  def initialize
    super(629, self.class.simple_name, "Clean Up The Swamp Of Screams")

    add_start_npc(PIERCE)
    add_talk_id(PIERCE)
    add_kill_id(MOBS_DROP_CHANCES.keys)
    register_quest_items(TALON_OF_STAKATO, GOLDEN_RAM_COIN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "31553-03.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "31553-04.html", "31553-06.html"
      if qs.started?
        html = event
      end
    when "31553-07.html"
      if qs.started? && get_quest_items_count(pc, TALON_OF_STAKATO) >= REQUIRED_TALON_COUNT
        reward_items(pc, GOLDEN_RAM_COIN, 20)
        take_items(pc, TALON_OF_STAKATO, 100)
        html = event
      else
        html = "31553-08.html"
      end
    when "31553-09.html"
      if qs.started?
        qs.exit_quest(true, true)
        html = event
      end
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_random_party_member_state(killer, -1, 2, npc)
    if qs
      give_item_randomly(qs.player, npc, TALON_OF_STAKATO, 1, 0, MOBS_DROP_CHANCES[npc.id], true)
    end

    super
  end

  def on_talk(npc, pc)
    unless qs = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    if qs.created?
      html = pc.level >= MIN_LVL ? "31553-01.htm" : "31553-02.htm"
    elsif qs.started?
      if get_quest_items_count(pc, TALON_OF_STAKATO) >= REQUIRED_TALON_COUNT
        html = "31553-04.html"
      else
        html = "31553-05.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
