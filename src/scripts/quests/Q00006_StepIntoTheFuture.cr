class Scripts::Q00006_StepIntoTheFuture < Quest
  # NPCs
  private ROXXY = 30006
  private BAULRO = 30033
  private SIR_COLLIN = 30311
  # Items
  private BAULRO_LETTER = 7571
  private SCROLL_OF_ESCAPE_GIRAN = 7559
  private MARK_OF_TRAVELER = 7570
  # Misc
  private MIN_LEVEL = 3

  def initialize
    super(6, self.class.simple_name, "Step Into the Future")

    add_start_npc(ROXXY)
    add_talk_id(ROXXY, BAULRO, SIR_COLLIN)
    register_quest_items(BAULRO_LETTER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30006-03.htm"
      st.start_quest
    when "30006-06.html"
      st.give_items(SCROLL_OF_ESCAPE_GIRAN, 1)
      st.give_items(MARK_OF_TRAVELER, 1)
      st.exit_quest(false, true)
    when "30033-02.html"
      st.set_cond(2, true)
      st.give_items(BAULRO_LETTER, 1)
    when "30311-02.html"
      if st.has_quest_items?(BAULRO_LETTER)
        st.take_items BAULRO_LETTER, -1
        st.set_cond(3, true)
      else
        return "30311-03.html"
      end
    else
      return
    end

    event
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when ROXXY
      case st.state
      when State::CREATED
        if pc.race.human? && pc.level >= MIN_LEVEL
          html = "30006-02.htm"
        else
          html = "30006-01.html"
        end
      when State::STARTED
        if st.cond?(1)
          html = "30006-04.html"
        elsif st.cond?(3)
          html = "30006-05.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when BAULRO
      if st.started?
        if st.cond?(1)
          html = "30033-01.html"
        elsif st.cond?(2)
          html = "30033-03.html"
        end
      end
    when SIR_COLLIN
      if st.started?
        if st.cond?(2)
          html = "30311-01.html"
        elsif st.cond?(3)
          html = "30311-04.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
