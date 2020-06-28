class Scripts::Q00009_IntoTheCityOfHumans < Quest
  # NPCs
  private PETUKAI = 30583
  private TANAPI = 30571
  private TAMIL = 30576
  # Items
  private SCROLL_OF_ESCAPE_GIRAN = 7559
  private MARK_OF_TRAVELER = 7570
  # Misc
  private MIN_LEVEL = 3

  def initialize
    super(9, self.class.simple_name, "Into the City of Humans")

    add_start_npc(PETUKAI)
    add_talk_id(PETUKAI, TANAPI, TAMIL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30583-04.htm"
      st.start_quest
    when "30576-02.html"
      st.give_items(MARK_OF_TRAVELER, 1)
      st.give_items(SCROLL_OF_ESCAPE_GIRAN, 1)
      st.exit_quest(false, true)
    when "30571-02.html"
      st.set_cond(2, true)
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
    when PETUKAI
      case st.state
      when State::CREATED
        if pc.level >= MIN_LEVEL
          if pc.race.orc?
            html = "30583-01.htm"
          else
            html = "30583-02.html"
          end
        else
          html = "30583-03.html"
        end
      when State::STARTED
        if st.cond?(1)
          html = "30583-05.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when TANAPI
      if st.started?
        html = st.cond?(1) ? "30571-01.html" : "30571-03.html"
      end
    when TAMIL
      if st.started? && st.cond?(2)
        html = "30576-01.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
