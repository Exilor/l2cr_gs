class Scripts::Q00008_AnAdventureBegins < Quest
  # NPCs
  private JASMINE = 30134
  private ROSELYN = 30355
  private HARNE = 30144
  # Items
  private ROSELYNS_NOTE = 7573
  private SCROLL_OF_ESCAPE_GIRAN = 7559
  private MARK_OF_TRAVELER = 7570
  # Misc
  private MIN_LEVEL = 3

  def initialize
    super(8, self.class.simple_name, "An Adventure Begins")

    add_start_npc(JASMINE)
    add_talk_id(JASMINE, ROSELYN, HARNE)
    register_quest_items(ROSELYNS_NOTE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30134-03.htm"
      st.start_quest
    when "30134-06.html"
      st.give_items(SCROLL_OF_ESCAPE_GIRAN, 1)
      st.give_items(MARK_OF_TRAVELER, 1)
      st.exit_quest(false, true)
    when "30355-02.html"
      st.set_cond(2, true)
      st.give_items(ROSELYNS_NOTE, 1)
    when "30144-02.html"
      unless st.has_quest_items?(ROSELYNS_NOTE)
        return "30144-03.html"
      end

      st.take_items(ROSELYNS_NOTE, -1)
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
    when JASMINE
      case st.state
      when State::CREATED
        if pc.race.dark_elf? && pc.level >= MIN_LEVEL
          html = "30134-02.htm"
        else
          html = "30134-01.html"
        end
      when State::STARTED
        if st.cond?(1)
          html = "30134-04.html"
        elsif st.cond?(3)
          html = "30134-05.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end
    when ROSELYN
      if st.started?
        if st.cond?(1)
          html = "30355-01.html"
        elsif st.cond?(2)
          html = "30355-03.html"
        end
      end
    when HARNE
      if st.started?
        if st.cond?(2)
          html = "30144-01.html"
        elsif st.cond?(3)
          html = "30144-04.html"
        end
      end
    else
      # [automatically added else]
    end

    html || get_no_quest_msg(pc)
  end
end
