class Scripts::Q00018_MeetingWithTheGoldenRam < Quest
  # NPCs
  private DONAL = 31314
  private DAISY = 31315
  private ABERCROMBIE = 31555
  # Item
  private BOX = 7245

  def initialize
    super(18, self.class.simple_name, "Meeting With The Golden Ram")

    add_start_npc(DONAL)
    add_talk_id(DONAL, DAISY, ABERCROMBIE)
    register_quest_items(BOX)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return html
    end

    case event
    when "31314-03.html"
      if pc.level >= 66
        st.start_quest
      else
        html = "31314-02.html"
      end
    when "31315-02.html"
      st.set_cond(2, true)
      st.give_items(BOX, 1)
    when "31555-02.html"
      if st.has_quest_items?(BOX)
        st.give_adena(40000, true)
        st.add_exp_and_sp(126668, 11731)
        st.exit_quest(false, true)
      end
    else
      # [automatically added else]
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    npc_id = npc.id

    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      if npc_id == DONAL
        html = "31314-01.htm"
      end
    when State::STARTED
      if npc_id == DONAL
        html = "31314-04.html"
      elsif npc_id == DAISY
        html = st.cond < 2 ? "31315-01.html" : "31315-03.html"
      elsif npc_id == ABERCROMBIE && st.cond?(2) && st.has_quest_items?(BOX)
        html = "31555-01.html"
      end
    else
      # [automatically added else]
    end

    html || get_no_quest_msg(pc)
  end
end
