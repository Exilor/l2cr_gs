class Scripts::Q00296_TarantulasSpiderSilk < Quest
  # NPCs
  private TRADER_MION = 30519
  private DEFENDER_NATHAN = 30548
  # Items
  private TARANTULA_SPIDER_SILK = 1493
  private TARANTULA_SPINNERETTE = 1494
  # Monsters
  private MONSTERS = {
    20394,
    20403,
    20508
  }
  # Misc
  private MIN_LVL = 15

  def initialize
    super(296, self.class.simple_name, "Tarantula's Spider Silk")

    add_start_npc(TRADER_MION)
    add_talk_id(TRADER_MION, DEFENDER_NATHAN)
    add_kill_id(MONSTERS)
    register_quest_items(TARANTULA_SPIDER_SILK, TARANTULA_SPINNERETTE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "30519-03.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30519-06.html"
      if qs.started?
        qs.exit_quest(true, true)
        html = event
      end
    when "30519-07.html"
      if qs.started?
        html = event
      end
    when "30548-03.html"
      if qs.started?
        if has_quest_items?(pc, TARANTULA_SPINNERETTE)
          amount = 15 &+ Rnd.rand(9)
          amount &*= get_quest_items_count(pc, TARANTULA_SPINNERETTE)
          give_items(pc, TARANTULA_SPIDER_SILK, amount)
          take_items(pc, TARANTULA_SPINNERETTE, -1)
          html = event
        else
          html = "30548-02.html"
        end
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && Util.in_range?(1500, npc, killer, true)
      chance = Rnd.rand(100)
      if chance > 95
        give_item_randomly(killer, npc, TARANTULA_SPINNERETTE, 1, 0, 1, true)
      elsif chance > 45
        give_item_randomly(killer, npc, TARANTULA_SPIDER_SILK, 1, 0, 1, true)
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created? && npc.id == TRADER_MION
      html = pc.level >= MIN_LVL ? "30519-02.htm" : "30519-01.htm"
    elsif qs.started?
      if npc.id == TRADER_MION
        silk = get_quest_items_count(pc, TARANTULA_SPIDER_SILK)
        if silk >= 1
          give_adena(pc, (silk &* 30) &+ (silk >= 10 ? 2000 : 0), true)
          take_items(pc, TARANTULA_SPIDER_SILK, -1)
          Q00281_HeadForTheHills.give_newbie_reward(pc) # TODO: It's using wrong bitmask, need to create a general bitmask for this using EnumIntBitmask class inside Quest class for handling Quest rewards.
          html = "30519-05.html"
        else
          html = "30519-04.html"
        end
      elsif npc.id == DEFENDER_NATHAN
        html = "30548-01.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
