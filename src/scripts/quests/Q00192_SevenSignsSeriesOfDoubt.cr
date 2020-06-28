class Scripts::Q00192_SevenSignsSeriesOfDoubt < Quest
  # NPCs
  private HOLLINT = 30191
  private HECTOR = 30197
  private STAN = 30200
  private CROOP = 30676
  private UNIDENTIFIED_BODY = 32568
  # Items
  private CROOPS_INTRODUCTION = 13813
  private JACOBS_NECKLACE = 13814
  private CROOPS_LETTER = 13815
  # Misc
  private MIN_LEVEL = 79

  def initialize
    super(192, self.class.simple_name, "Seven Signs, Series of Doubt")

    add_start_npc(CROOP, UNIDENTIFIED_BODY)
    add_talk_id(CROOP, STAN, UNIDENTIFIED_BODY, HECTOR, HOLLINT)
    register_quest_items(CROOPS_INTRODUCTION, JACOBS_NECKLACE, CROOPS_LETTER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30676-02.htm"
      html = event
    when "30676-03.html"
      st.start_quest
      html = event
    when "video"
      if st.cond?(1)
        st.set_cond(2, true)
        pc.show_quest_movie(8)
        start_quest_timer("back", 32000, npc, pc)
        return ""
      end
    when "back"
      pc.tele_to_location(81654, 54851, -1513)
      return ""
    when "30676-10.html", "30676-11.html", "30676-12.html", "30676-13.html"
      if st.cond?(6) && st.has_quest_items?(JACOBS_NECKLACE)
        html = event
      end
    when "30676-14.html"
      if st.cond?(6) && st.has_quest_items?(JACOBS_NECKLACE)
        st.give_items(CROOPS_LETTER, 1)
        st.take_items(JACOBS_NECKLACE, -1)
        st.set_cond(7, true)
        html = event
      end
    when "30200-02.html", "30200-03.html"
      if st.cond?(4)
        html = event
      end
    when "30200-04.html"
      if st.cond?(4)
        st.set_cond(5, true)
        html = event
      end
    when "32568-02.html"
      if st.cond?(5)
        st.give_items(JACOBS_NECKLACE, 1)
        st.set_cond(6, true)
        html = event
      end
    when "30197-02.html"
      if st.cond?(3) && st.has_quest_items?(CROOPS_INTRODUCTION)
        html = event
      end
    when "30197-03.html"
      if st.cond?(3) && st.has_quest_items?(CROOPS_INTRODUCTION)
        st.take_items(CROOPS_INTRODUCTION, -1)
        st.set_cond(4, true)
        html = event
      end
    when "30191-02.html"
      if st.cond?(7) && st.has_quest_items?(CROOPS_LETTER)
        html = event
      end
    when "reward"
      if st.cond?(7) && st.has_quest_items?(CROOPS_LETTER)
        if pc.level >= MIN_LEVEL
          st.add_exp_and_sp(52518015, 5817677)
          st.exit_quest(false, true)
          html = "30191-03.html"
        else
          html = "level_check.html"
        end
      end
    end


    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      if npc.id == CROOP
        html = "30676-05.html"
      elsif npc.id == UNIDENTIFIED_BODY
        html = "32568-04.html"
      end
    when State::CREATED
      if npc.id == CROOP
        html = pc.level >= MIN_LEVEL ? "30676-01.htm" : "30676-04.html"
      elsif npc.id == UNIDENTIFIED_BODY
        html = "32568-04.html"
      end
    when State::STARTED
      case npc.id
      when CROOP
        case st.cond
        when 1
          html = "30676-06.html"
        when 2
          st.give_items(CROOPS_INTRODUCTION, 1)
          st.set_cond(3, true)
          html = "30676-07.html"
        when 3..5
          html = "30676-08.html"
        when 6
          if st.has_quest_items?(JACOBS_NECKLACE)
            html = "30676-09.html"
          end
        end

      when HECTOR
        if st.cond?(3)
          if st.has_quest_items?(CROOPS_INTRODUCTION)
            html = "30197-01.html"
          end
        elsif st.cond > 3
          html = "30197-04.html"
        end
      when STAN
        if st.cond?(4)
          html = "30200-01.html"
        elsif st.cond > 4
          html = "30200-05.html"
        end
      when UNIDENTIFIED_BODY
        if st.cond?(5)
          html = "32568-01.html"
        elsif st.cond < 5
          html = "32568-03.html"
        end
      when HOLLINT
        if st.cond?(7) && st.has_quest_items?(CROOPS_LETTER)
          html = "30191-01.html"
        end
      end

    end


    html || get_no_quest_msg(pc)
  end
end
