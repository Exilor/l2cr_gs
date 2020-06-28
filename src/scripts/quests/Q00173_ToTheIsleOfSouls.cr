class Scripts::Q00173_ToTheIsleOfSouls < Quest
  # NPCs
  private GALLADUCCI = 30097
  private GENTLER = 30094

  # Items
  private GALLADUCCIS_ORDER = 7563
  private MAGIC_SWORD_HILT = 7568
  private MARK_OF_TRAVELER = 7570
  private SCROLL_OF_ESCAPE_KAMAEL_VILLAGE = 9716

  def initialize
    super(173, self.class.simple_name, "To the Isle of Souls")

    add_start_npc(GALLADUCCI)
    add_talk_id(GALLADUCCI, GENTLER)
    register_quest_items(GALLADUCCIS_ORDER, MAGIC_SWORD_HILT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "30097-03.htm"
      st.start_quest
      st.give_items(GALLADUCCIS_ORDER, 1)
    when "30097-06.html"
      st.give_items(SCROLL_OF_ESCAPE_KAMAEL_VILLAGE, 1)
      st.take_items(MARK_OF_TRAVELER, 1)
      st.exit_quest(false, true)
    when "30094-02.html"
      st.set_cond(2, true)
      st.take_items(GALLADUCCIS_ORDER, -1)
      st.give_items(MAGIC_SWORD_HILT, 1)
    else
      return
    end

    html
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when GALLADUCCI
      case st.state
      when State::CREATED
        if pc.race.kamael? && pc.quest_completed?(Q00172_NewHorizons.simple_name) && st.has_quest_items?(MARK_OF_TRAVELER)
          html = "30097-01.htm"
        else
          html = "30097-02.htm"
        end
      when State::STARTED
        html = st.cond?(1) ? "30097-04.html" : "30097-05.html"
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end

    when GENTLER
      if st.started?
        html = st.cond?(1) ? "30094-01.html" : "30094-03.html"
      end
    end


    html || get_no_quest_msg(pc)
  end
end
