class Scripts::Q00347_GoGetTheCalculator < Quest
  # NPCs
  private BRUNON = 30526
  private SILVERA = 30527
  private SPIRON = 30532
  private BALANKI = 30533
  # Items
  private STOLEN_CALCULATOR = 4285
  private GEMSTONE = 4286
  # Monster
  private GEMSTONE_BEAST = 20540
  # Reward
  private CALCULATOR = 4393
  private ADENA = 1500i64
  # Misc
  private MIN_LVL = 12

  def initialize
    super(347, self.class.simple_name, "Go Get the Calculator")

    add_start_npc(BRUNON)
    add_talk_id(BRUNON, SILVERA, SPIRON, BALANKI)
    add_kill_id(GEMSTONE_BEAST)
    register_quest_items(STOLEN_CALCULATOR, GEMSTONE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "30526-03.htm", "30526-04.htm", "30526-05.htm", "30526-06.htm",
         "30526-07.htm", "30532-03.html", "30532-04.html"
      html = event
    when "30526-08.htm"
      if qs.created?
        qs.start_quest
        html = event
      end
    when "30526-10.html"
      if qs.cond?(6)
        take_items(pc, STOLEN_CALCULATOR, -1)
        reward_items(pc, CALCULATOR, 1)
        qs.exit_quest(true, true)
        html = event
      else
        html = "30526-09.html"
      end
    when "30526-11.html"
      if qs.cond?(6)
        take_items(pc, STOLEN_CALCULATOR, -1)
        give_adena(pc, ADENA, true)
        qs.exit_quest(true, true)
        html = event
      end
    when "30532-02.html"
      if qs.cond?(1)
        qs.set_cond(2, true)
        html = event
      end
    when "30533-02.html"
      if qs.cond?(2) && pc.adena > 100
        take_items(pc, Inventory::ADENA_ID, 100)
        qs.set_cond(3, true)
        html = event
      end
    end

    html
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    case qs.state
    when State::CREATED
      if npc.id == BRUNON
        html = pc.level >= MIN_LVL ? "30526-01.htm" : "30526-02.html"
      end
    when State::STARTED
      case npc.id
      when BRUNON
        if has_quest_items?(pc, CALCULATOR)
          qs.set_cond(6)
        end

        case qs.cond
        when 1, 2
          html = "30526-13.html"
        when 3, 4
          html = "30526-14.html"
        when 5
          html = "30526-15.html"
        when 6
          html = "30526-09.html"
        end
      when SPIRON
        html = qs.cond?(1) ? "30532-01.html" : "30532-05.html"
      when BALANKI
        if qs.cond?(2)
          html = "30533-01.html"
        elsif qs.cond > 2
          html = "30533-04.html"
        else
          html = "30533-03.html"
        end
      when SILVERA
        case qs.cond
        when 1, 2
          html = "30527-01.html"
        when 3
          qs.set_cond(4, true)
          html = "30527-02.html"
        when 4
          html = "30527-04.html"
        when 5
          take_items(pc, GEMSTONE, -1)
          give_items(pc, STOLEN_CALCULATOR, 1)
          qs.set_cond(6, true)
          html = "30527-03.html"
        when 6
          html = "30527-05.html"
        end
      end
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    end

    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    if qs = get_random_party_member_state(killer, 4, 3, npc)
      if give_item_randomly(qs.player, npc, GEMSTONE, 1, 10, 0.4, true)
        qs.set_cond(5)
      end
    end

    super
  end
end
