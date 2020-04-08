class Scripts::Q00237_WindsOfChange < Quest
  # NPCs
  private FLAUEN = 30899
  private IASON = 30969
  private ROMAN = 30897
  private MORELYN = 30925
  private HELVETICA = 32641
  private ATHENIA = 32643
  # Items
  private FLAUENS_LETTER = 14862
  private DOSKOZER_LETTER = 14863
  private ATHENIA_LETTER = 14864
  private VICINITY_OF_FOS = 14865
  private SUPPORT_CERTIFICATE = 14866
  # Misc
  private MIN_LEVEL = 82

  def initialize
    super(237, self.class.simple_name, "Winds of Change")

    add_start_npc(FLAUEN)
    add_talk_id(FLAUEN, IASON, ROMAN, MORELYN, HELVETICA, ATHENIA)
    register_quest_items(FLAUENS_LETTER, DOSKOZER_LETTER, ATHENIA_LETTER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = nil
    case event
    when "30899-02.htm", # FLAUEN
         "30899-03.htm",
         "30899-04.htm",
         "30899-05.htm",
         "30969-03.html", # IASON
         "30969-03a.html",
         "30969-03b.html",
         "30969-04.html",
         "30969-08.html",
         "30969-08a.html",
         "30969-08b.html",
         "30969-08c.html",
         "30897-02.html", # ROMAN
         "30925-02.html" # MORELYN
      html = event
    when "30899-06.html"
      st.start_quest
      st.give_items(FLAUENS_LETTER, 1)
      html = event
    when "30969-02.html"
      st.take_items(FLAUENS_LETTER, -1)
      html = event
    when "30969-05.html"
      if st.cond?(1)
        st.set_cond(2, true)
        html = event
      end
    when "30897-03.html"
      if st.cond?(2)
        st.set_cond(3, true)
        html = event
      end
    when "30925-03.html"
      if st.cond?(3)
        st.set_cond(4, true)
        html = event
      end
    when "30969-09.html"
      if st.cond?(4)
        st.give_items(DOSKOZER_LETTER, 1)
        st.set_cond(5, true)
        html = event
      end
    when "30969-10.html"
      if st.cond?(4)
        st.give_items(ATHENIA_LETTER, 1)
        st.set_cond(6, true)
        html = event
      end
    when "32641-02.html"
      st.give_adena(213876, true)
      st.give_items(VICINITY_OF_FOS, 1)
      st.add_exp_and_sp(892773, 60012)
      st.exit_quest(false, true)
      html = event
    when "32643-02.html"
      st.give_adena(213876, true)
      st.give_items(SUPPORT_CERTIFICATE, 1)
      st.add_exp_and_sp(892773, 60012)
      st.exit_quest(false, true)
      html = event
    else
      # automatically added
    end


    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when FLAUEN
      case st.state
      when State::COMPLETED
        html = "30899-09.html"
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "30899-01.htm" : "30899-00.html"
      when State::STARTED
        case st.cond
        when 1, 4
          html = "30899-07.html"
        when 2
          html = "30899-10.html"
        when 3
          html = "30899-11.html"
        when 5, 6
          html = "30899-08.html"
        else
          # automatically added
        end

      else
        # automatically added
      end

    when IASON
      if st.completed?
        html = get_no_quest_msg(pc)
      else
        case st.cond
        when 1
          html = "30969-01.html"
        when 2
          html = "30969-06.html"
        when 4
          html = "30969-07.html"
        when 5, 6
          html = "30969-11.html"
        else
          # automatically added
        end

      end
    when ROMAN
      case st.cond
      when 2
        html = "30897-01.html"
      when 3, 4
        html = "30897-04.html"
      else
        # automatically added
      end

    when MORELYN
      case st.cond
      when 3
        html = "30925-01.html"
      when 4
        html = "30925-04.html"
      else
        # automatically added
      end

    when HELVETICA
      if st.completed?
        if st.has_quest_items?(VICINITY_OF_FOS) || st.player.quest_completed?(Q00238_SuccessFailureOfBusiness.simple_name)
          html = "32641-03.html"
        else
          html = "32641-05.html"
        end
      elsif st.cond?(5)
        html = "32641-01.html"
      elsif st.cond?(6)
        html = "32641-04.html"
      end
    when ATHENIA
      if st.completed?
        if st.has_quest_items?(SUPPORT_CERTIFICATE) || st.player.quest_completed?(Q00239_WontYouJoinUs.simple_name)
          html = "32643-03.html"
        else
          html = "32643-05.html"
        end
      elsif st.cond?(5)
        html = "32643-04.html"
      elsif st.cond?(6)
        html = "32643-01.html"
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end