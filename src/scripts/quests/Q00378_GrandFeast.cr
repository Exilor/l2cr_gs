class Scripts::Q00378_GrandFeast < Quest
  # NPC
  private RANSPO = 30594
  # Items
  private JONAS_SALAD_RECIPE = 1455
  private JONAS_SAUCE_RECIPE = 1456
  private JONAS_STEAK_RECIPE = 1457
  private THEME_OF_THE_FEAST = 4421
  private OLD_WINE_15_YEAR = 5956
  private OLD_WINE_30_YEAR = 5957
  private OLD_WINE_60_YEAR = 5958
  private RITRONS_DESSERT_RECIPE = 5959
  # Rewards
  private CORAL_EARRING = 846
  private RED_CRESCENT_EARRING = 847
  private ENCHANTED_EARRING = 848
  private ENCHANTED_RING = 879
  private RING_OF_DEVOTION = 890
  private BLUE_DIAMOND_NECKLACE = 909
  private NECKLACE_OF_DEVOTION = 910
  # Misc
  private MIN_LEVEL = 20

  def initialize
    super(378, self.class.simple_name, "Grand Feast")

    add_start_npc(RANSPO)
    add_talk_id(RANSPO)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30594-02.htm"
      qs.set_memo_state_ex(1, 0)
      qs.start_quest
      html = event
    when "30594-05.html"
      i0 = qs.get_memo_state_ex(1)
      if has_quest_items?(pc, OLD_WINE_15_YEAR)
        take_items(pc, OLD_WINE_15_YEAR, 1)
        qs.set_memo_state_ex(1, i0 + 10)
        qs.set_cond(2, true)
        html = event
      else
        html = "30594-08.html"
      end
    when "30594-06.html"
      i0 = qs.get_memo_state_ex(1)
      if has_quest_items?(pc, OLD_WINE_30_YEAR)
        take_items(pc, OLD_WINE_30_YEAR, 1)
        qs.set_memo_state_ex(1, i0 + 20)
        qs.set_cond(2, true)
        html = event
      else
        html = "30594-08.html"
      end
    when "30594-07.html"
      i0 = qs.get_memo_state_ex(1)
      if has_quest_items?(pc, OLD_WINE_60_YEAR)
        take_items(pc, OLD_WINE_60_YEAR, 1)
        qs.set_memo_state_ex(1, i0 + 30)
        qs.set_cond(2, true)
        html = event
      else
        html = "30594-08.html"
      end
    when "30594-09.html", "30594-18.html"
      html = event
    when "30594-12.html"
      if has_quest_items?(pc, THEME_OF_THE_FEAST)
        take_items(pc, THEME_OF_THE_FEAST, 1)
        qs.set_cond(3, true)
        html = event
      else
        html = "30594-08.html"
      end
    when "30594-14.html"
      i0 = qs.get_memo_state_ex(1)
      if has_quest_items?(pc, JONAS_SALAD_RECIPE)
        take_items(pc, JONAS_SALAD_RECIPE, 1)
        qs.set_memo_state_ex(1, i0 + 1)
        qs.set_cond(4, true)
        html = event
      else
        html = "30594-17.html"
      end
    when "30594-15.html"
      i0 = qs.get_memo_state_ex(1)
      if has_quest_items?(pc, JONAS_SAUCE_RECIPE)
        take_items(pc, JONAS_SAUCE_RECIPE, 1)
        qs.set_memo_state_ex(1, i0 + 2)
        qs.set_cond(4, true)
        html = event
      else
        html = "30594-17.html"
      end
    when "30594-16.html"
      i0 = qs.get_memo_state_ex(1)
      if has_quest_items?(pc, JONAS_STEAK_RECIPE)
        take_items(pc, JONAS_STEAK_RECIPE, 1)
        qs.set_memo_state_ex(1, i0 + 3)
        qs.set_cond(4, true)
        html = event
      else
        html = "30594-17.html"
      end
    end

    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      html = pc.level >= MIN_LEVEL ? "30594-01.htm" : "30594-03.html"
    elsif qs.started?
      case qs.cond
      when 1
        html = "30594-04.html"
      when 2
        if has_quest_items?(pc, THEME_OF_THE_FEAST)
          html = "30594-11.html"
        else
          html = "30594-10.html"
        end
      when 3
        html = "30594-13.html"
      when 4
        if has_quest_items?(pc, RITRONS_DESSERT_RECIPE)
          take_items(pc, RITRONS_DESSERT_RECIPE, 1)
          item = 0
          adena = 0i64
          quantity = 0i64
          case qs.get_memo_state_ex(1)
          when 11
            item = RED_CRESCENT_EARRING
            quantity = 1i64
            adena = 5700i64
          when 12
            item = CORAL_EARRING
            quantity = 2i64
            adena = 1200i64
          when 13
            item = ENCHANTED_RING
            quantity = 1i64
            adena = 8100i64
          when 21
            item = CORAL_EARRING
            quantity = 2i64
          when 22
            item = ENCHANTED_RING
            quantity = 1i64
            adena = 6900i64
          when 23
            item = NECKLACE_OF_DEVOTION
            quantity = 1i64
          when 31
            item = BLUE_DIAMOND_NECKLACE
            quantity = 1i64
            adena = 25400i64
          when 32
            item = RING_OF_DEVOTION
            quantity = 2i64
            adena = 8500i64
          when 33
            item = ENCHANTED_EARRING
            quantity = 1i64
            adena = 2200i64
          end

          give_items(pc, item, quantity)
          give_adena(pc, adena, true)
          qs.exit_quest(true, true)
          html = "30594-20.html"
        else
          html = "30594-19.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
