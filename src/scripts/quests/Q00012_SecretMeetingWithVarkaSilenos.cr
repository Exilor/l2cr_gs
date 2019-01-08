class Quests::Q00012_SecretMeetingWithVarkaSilenos < Quest
  # NPCs
	private CADMON = 31296
	private HELMUT = 31258
	private NARAN  = 31378
	# Item
	private BOX = 7232

  def initialize
    super(12, self.class.simple_name, "Secret Meeting With Varka Silenos")

    add_start_npc(CADMON)
    add_talk_id(CADMON, HELMUT, NARAN)
    register_quest_items(BOX)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return event unless st = get_quest_state(pc, false)

    case event
    when "31296-03.html"
      st.start_quest
    when "31258-02.html"
      if st.cond?(1)
        st.set_cond(2, true)
        st.give_items(BOX, 1)
      end
    when "31378-02.html"
      if st.cond?(2) && st.has_quest_items?(BOX)
        st.add_exp_and_sp(233125, 18142)
        st.exit_quest(false, true)
      else
        return "31378-03.html"
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
      elsif npc.id == HELMUT
        if st.cond?(1)
          htmltext = "31258-01.html"
        elsif st.cond?(2)
          htmltext = "31258-03.html"
        end
      elsif npc.id == NARAN && st.cond?(2)
        htmltext = "31378-01.html"
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(pc)
    end

    htmltext
  end
end
