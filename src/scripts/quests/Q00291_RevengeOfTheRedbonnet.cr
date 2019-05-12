class Scripts::Q00291_RevengeOfTheRedbonnet < Quest
  # NPC
  private MARYSE_REDBONNET = 30553
  # Item
  private BLACK_WOLF_PELT = ItemHolder.new(1482, 40)
  # Monster
  private BLACK_WOLF = 20317
  # Rewards
  private SCROLL_OF_ESCAPE = 736
  private GRANDMAS_PEARL = 1502
  private GRANDMAS_MIRROR = 1503
  private GRANDMAS_NECKLACE = 1504
  private GRANDMAS_HAIRPIN = 1505
  # Misc
  private MIN_LVL = 4

  def initialize
    super(291, self.class.simple_name, "Revenge of the Redbonnet")

    add_start_npc(MARYSE_REDBONNET)
    add_talk_id(MARYSE_REDBONNET)
    add_kill_id(BLACK_WOLF)
    register_quest_items(BLACK_WOLF_PELT.id)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    qs = get_quest_state(pc, false)
    if qs && event == "30553-03.htm"
      qs.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.cond?(1) && Util.in_range?(1500, npc, killer, true)
      if give_item_randomly(qs.player, npc, BLACK_WOLF_PELT.id, 1, BLACK_WOLF_PELT.count, 1.0, true)
        qs.set_cond(2)
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    if qs.created?
      html = pc.level >= MIN_LVL ? "30553-02.htm" : "30553-01.htm"
    elsif qs.started?
      if qs.cond?(2) && has_item?(pc, BLACK_WOLF_PELT)
        take_item(pc, BLACK_WOLF_PELT)
        chance = Rnd.rand(100)
        if chance <= 2
          give_items(pc, GRANDMAS_PEARL, 1)
        elsif chance <= 20
          give_items(pc, GRANDMAS_MIRROR, 1)
        elsif chance <= 45
          give_items(pc, GRANDMAS_NECKLACE, 1)
        else
          give_items(pc, GRANDMAS_HAIRPIN, 1)
          give_items(pc, SCROLL_OF_ESCAPE, 1)
        end
        qs.exit_quest(true, true)
        html = "30553-05.html"
      else
        html = "30553-04.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
