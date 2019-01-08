class Quests::Q00011_SecretMeetingWithKetraOrcs < Quest
  # NPCs
	private CADMON = 31296
	private LEON = 31256
	private WAHKAN = 31371
	# Item
	private BOX = 7231

  def initialize
    super(11, self.class.simple_name, "Secret Meeting With Ketra Orcs")

    add_start_npc(CADMON)
    add_talk_id(CADMON, LEON, WAHKAN)
    register_quest_items(BOX)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return event unless st = get_quest_state(pc, false)

    case event
    when "31296-03.html"
      st.start_quest
    when "31256-02.html"
      if st.cond?(1)
        st.set_cond(2, true)
        st.give_items(BOX, 1)
      end
    when "31371-02.html"
      if st.cond?(2) && st.has_quest_items?(BOX)
        st.add_exp_and_sp(233125, 18142)
        st.exit_quest(false, true)
      else
        return "31371-03.html"
      end
    end

    event
  end

  def on_talk(npc, pc)
    htmltext = get_no_quest_msg(pc)
    return htmltext unless st = get_quest_state(pc, true)

    case st.state
    when State::CREATED
      if npc.id == CADMON
        htmltext = pc.level >= 74 ? "31296-01.htm" : "31296-02.html"
      end
    when State::STARTED
      if npc.id == CADMON && st.cond?(1)
        htmltext = "31296-04.html"
      elsif npc.id == LEON
        if st.cond?(1)
          htmltext = "31256-01.html"
        elsif st.cond?(2)
          htmltext = "31256-03.html"
        end
      elsif npc.id == WAHKAN && st.cond?(2)
        htmltext = "31371-01.html"
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(pc)
    end

    htmltext
  end
end
