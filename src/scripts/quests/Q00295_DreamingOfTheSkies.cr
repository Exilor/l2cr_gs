class Scripts::Q00295_DreamingOfTheSkies < Quest
  # NPC
  private ARIN = 30536
  # Monster
  private MAGICAL_WEAVER = 20153
  # Item
  private FLOATING_STONE = 1492
  # Reward
  private RING_OF_FIREFLY = 1509
  # Misc
  private MIN_LVL = 11

  def initialize
    super(295, self.class.simple_name, "Dreaming of the Skies")

    add_start_npc(ARIN)
    add_talk_id(ARIN)
    add_kill_id(MAGICAL_WEAVER)
    register_quest_items(FLOATING_STONE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    qs = get_quest_state(pc, false)
    if qs && qs.created? && event == "30536-03.htm"
      qs.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.cond?(1) && Util.in_range?(1500, npc, killer, true)
      amount = Rnd.rand(100) > 25 ? 1 : 2
      if give_item_randomly(killer, npc, FLOATING_STONE, amount, 50, 1.0, true)
        qs.set_cond(2)
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LVL ? "30536-02.htm" : "30536-01.htm"
    elsif qs.started?
      if qs.cond?(2)
        if has_quest_items?(pc, RING_OF_FIREFLY)
          give_adena(pc, 2400, true)
          html = "30536-06.html"
        else
          give_items(pc, RING_OF_FIREFLY, 1)
          html = "30536-05.html"
        end
        take_items(pc, FLOATING_STONE, -1)
        qs.exit_quest(true, true)
      else
        html = "30536-04.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
