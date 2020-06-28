class Scripts::Q00155_FindSirWindawood < Quest
  # NPCs
  private ABELLOS = 30042
  private SIR_COLLIN_WINDAWOOD = 30311
  # Items
  private OFFICIAL_LETTER = 1019
  private HASTE_POTION = 734
  # Misc
  private MIN_LEVEL = 3

  def initialize
    super(155, self.class.simple_name, "Find Sir Windawood")

    add_start_npc(ABELLOS)
    add_talk_id(ABELLOS, SIR_COLLIN_WINDAWOOD)
    register_quest_items(OFFICIAL_LETTER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event.casecmp?("30042-03.htm")
      st.start_quest
      st.give_items(OFFICIAL_LETTER, 1)
      event
    end
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when ABELLOS
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "30042-02.htm" : "30042-01.htm"
      when State::STARTED
        html = "30042-04.html"
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end

    when SIR_COLLIN_WINDAWOOD
      if st.started? && st.has_quest_items?(OFFICIAL_LETTER)
        st.give_items(HASTE_POTION, 1)
        st.exit_quest(false, true)
        html = "30311-01.html"
      end
    end


    html || get_no_quest_msg(pc)
  end
end
