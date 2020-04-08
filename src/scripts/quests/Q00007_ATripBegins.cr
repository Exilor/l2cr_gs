class Scripts::Q00007_ATripBegins < Quest
  # NPCs
  private MIRABEL = 30146
  private ARIEL = 30148
  private ASTERIOS = 30154
  # Items
  private ARIELS_RECOMMENDATION = 7572
  private SCROLL_OF_ESCAPE_GIRAN = 7559
  private MARK_OF_TRAVELER = 7570
  # Misc
  private MIN_LEVEL = 3

  def initialize
    super(7, self.class.simple_name, "A Trip Begins")

    add_start_npc(MIRABEL)
    add_talk_id(MIRABEL, ARIEL, ASTERIOS)
    register_quest_items(ARIELS_RECOMMENDATION)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30146-03.htm"
      st.start_quest
    when "30146-06.html"
      st.give_items(SCROLL_OF_ESCAPE_GIRAN, 1)
      st.give_items(MARK_OF_TRAVELER, 1)
      st.exit_quest(false, true)
    when "30148-02.html"
      st.set_cond(2, true)
      st.give_items(ARIELS_RECOMMENDATION, 1)
    when "30154-02.html"
      unless st.has_quest_items?(ARIELS_RECOMMENDATION)
        return "30154-03.html"
      end

      st.take_items(ARIELS_RECOMMENDATION, -1)
      st.set_cond(3, true)
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
    when MIRABEL
      case st.state
      when State::CREATED
        if pc.race.elf? && pc.level >= MIN_LEVEL
          html = "30146-01.htm"
        else
          html = "30146-02.html"
        end
      when State::STARTED
        if st.cond?(1)
          html = "30146-04.html"
        elsif st.cond?(3)
          html = "30146-05.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # automatically added
      end

    when ARIEL
      if st.started?
        if st.cond?(1)
          html = "30148-01.html"
        elsif st.cond?(2)
          html = "30148-03.html"
        end
      end
    when ASTERIOS
      if st.started?
        if st.cond?(2)
          html = "30154-01.html"
        elsif st.cond?(3)
          html = "30154-04.html"
        end
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end
