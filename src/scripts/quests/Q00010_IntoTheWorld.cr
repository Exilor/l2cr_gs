class Scripts::Q00010_IntoTheWorld < Quest
  # NPCs
  private REED = 30520
  private BALANKI = 30533
  private GERALD = 30650
  # Items
  private VERY_EXPENSIVE_NECKLACE = 7574
  private SCROLL_OF_ESCAPE_GIRAN = 7559
  private MARK_OF_TRAVELER = 7570
  # Misc
  private MIN_LEVEL = 3

  def initialize
    super(10, self.class.simple_name, "Into the World")

    add_start_npc(BALANKI)
    add_talk_id(BALANKI, REED, GERALD)
    register_quest_items(VERY_EXPENSIVE_NECKLACE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30533-03.htm"
      st.start_quest
    when "30533-06.html"
      st.give_items(MARK_OF_TRAVELER, 1)
      st.give_items(SCROLL_OF_ESCAPE_GIRAN, 1)
      st.exit_quest(false, true)
    when "30520-02.html"
      st.give_items(VERY_EXPENSIVE_NECKLACE, 1)
      st.set_cond(2, true)
    when "30520-05.html"
      st.set_cond(4, true)
    when "30650-02.html"
      unless st.has_quest_items?(VERY_EXPENSIVE_NECKLACE)
        return "30650-03.html"
      end

      st.take_items(VERY_EXPENSIVE_NECKLACE, -1)
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
    when BALANKI
      case st.state
      when State::CREATED
        if pc.level >= MIN_LEVEL && pc.race.dwarf?
          html = "30533-01.htm"
        else
          html = "30533-02.html"
        end
      when State::STARTED
        if st.cond?(1)
          html = "30533-04.html"
        elsif st.cond?(4)
          html = "30533-05.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end
    when REED
      if st.started?
        case st.cond
        when 1
          html = "30520-01.html"
        when 2
          html = "30520-03.html"
        when 3
          html = "30520-04.html"
        when 4
          html = "30520-06.html"
        else
          # [automatically added else]
        end
      end
    when GERALD
      if st.started?
        if st.cond?(2)
          html = "30650-01.html"
        elsif st.cond?(3)
          html = "30650-04.html"
        end
      end
    else
      # [automatically added else]
    end

    html || get_no_quest_msg(pc)
  end
end
