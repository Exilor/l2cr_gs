class Quests::Q00018_MeetingWithTheGoldenRam < Quest
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

  def on_adv_event(event, npc, player)
    return unless player
    htmltext = event
    unless st = get_quest_state(player, false)
      return htmltext
    end

    case event
    when "31314-03.html"
      if player.level >= 66
        st.start_quest
      else
        htmltext = "31314-02.html"
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
    end

    htmltext
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    npc_id = npc.id

    case st.state
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    when State::CREATED
      if npc_id == DONAL
        htmltext = "31314-01.htm"
      end
    when State::STARTED
      if npc_id == DONAL
        htmltext = "31314-04.html"
      elsif npc_id == DAISY
        htmltext = st.cond < 2 ? "31315-01.html" : "31315-03.html"
      elsif npc_id == ABERCROMBIE && st.cond?(2) && st.has_quest_items?(BOX)
        htmltext = "31555-01.html"
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
