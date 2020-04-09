class Scripts::Q00040_ASpecialOrder < Quest
  # NPCs
  private HELVETIA = 30081
  private OFULLE = 31572
  private GESTO = 30511
  # Items
  private ORANGE_SWIFT_FISH = 6450
  private ORANGE_UGLY_FISH = 6451
  private ORANGE_WIDE_FISH = 6452
  private GOLDEN_COBOL = 5079
  private BUR_COBOL = 5082
  private GREAT_COBOL = 5084
  private WONDROUS_CUBIC = 10632
  private BOX_OF_FISH = 12764
  private BOX_OF_SEED = 12765
  # Misc
  private MIN_LVL = 40

  def initialize
    super(40, self.class.simple_name, "A Special Order")

    add_start_npc(HELVETIA)
    add_talk_id(HELVETIA, OFULLE, GESTO)
    register_quest_items(BOX_OF_FISH, BOX_OF_SEED)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "accept"
      st.start_quest
      if Rnd.bool
        st.set_cond(2)
        html = "30081-03.html"
      else
        st.set_cond(5)
        html = "30081-04.html"
      end
    when "30081-07.html"
      if st.cond?(4) && st.has_quest_items?(BOX_OF_FISH)
        st.reward_items(WONDROUS_CUBIC, 1)
        st.exit_quest(false, true)
        html = event
      end
    when "30081-10.html"
      if st.cond?(7) && st.has_quest_items?(BOX_OF_SEED)
        st.reward_items(WONDROUS_CUBIC, 1)
        st.exit_quest(false, true)
        html = event
      end
    when "31572-02.html", "30511-02.html"
      html = event
    when "31572-03.html"
      if st.cond?(2)
        st.set_cond(3, true)
        html = event
      end
    when "30511-03.html"
      if st.cond?(5)
        st.set_cond(6, true)
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    html = get_no_quest_msg(pc)
    case npc.id
    when HELVETIA
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LVL ? "30081-01.htm" : "30081-02.htm"
      when State::STARTED
        case st.cond
        when 2, 3
          html = "30081-05.html"
        when 4
          if st.has_quest_items?(BOX_OF_FISH)
            html = "30081-06.html"
          end
        when 5, 6
          html = "30081-08.html"
        when 7
          if st.has_quest_items?(BOX_OF_SEED)
            html = "30081-09.html"
          end
        else
          # [automatically added else]
        end

      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end

    when OFULLE
      case st.cond
      when 2
        html = "31572-01.html"
      when 3
        if st.get_quest_items_count(ORANGE_SWIFT_FISH) >= 10 && st.get_quest_items_count(ORANGE_UGLY_FISH) >= 10 && st.get_quest_items_count(ORANGE_WIDE_FISH) >= 10
          st.set_cond(4, true)
          st.give_items(BOX_OF_FISH, 1)
          take_items(pc, 10, {ORANGE_SWIFT_FISH, ORANGE_UGLY_FISH, ORANGE_WIDE_FISH})
          html = "31572-05.html"
        else
          html = "31572-04.html"
        end
      when 4
        html = "31572-06.html"
      else
        # [automatically added else]
      end

    when GESTO
      case st.cond
      when 5
        html = "30511-01.html"
      when 6
        if st.get_quest_items_count(GOLDEN_COBOL) >= 40 && st.get_quest_items_count(BUR_COBOL) >= 40 && st.get_quest_items_count(GREAT_COBOL) >= 40
          st.set_cond(7, true)
          st.give_items(BOX_OF_SEED, 1)
          take_items(pc, 40, {GOLDEN_COBOL, BUR_COBOL, GREAT_COBOL})
          html = "30511-05.html"
        else
          html = "30511-04.html"
        end
      when 7
        html = "30511-06.html"
      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
