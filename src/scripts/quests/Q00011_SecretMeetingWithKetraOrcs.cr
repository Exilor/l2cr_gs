class Scripts::Q00011_SecretMeetingWithKetraOrcs < Quest
  # NPCs
	private CADMON = 31296
	private LEON = 31256
	private WAHKAN = 31371
	# Item
	private MUNITIONS_BOX = 7231

  private MIN_LEVEL = 74

  def initialize
    super(11, self.class.simple_name, "Secret Meeting With Ketra Orcs")

    add_start_npc(CADMON)
    add_talk_id(CADMON, LEON, WAHKAN)
    register_quest_items(MUNITIONS_BOX)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    case event
    when "31296-03.htm"
      st.start_quest
      st.memo_state = 11
      event
    when "31256-02.html"
      give_items(pc, MUNITIONS_BOX, 1)
      st.memo_state = 21
      st.set_cond(2, true)
      event
    when "31371-02.html"
      if has_quest_items?(pc, MUNITIONS_BOX)
        add_exp_and_sp(pc, 233125, 18142)
        st.exit_quest(false, true)
        event
      else
        "31371-03.html"
      end
    end
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if npc.id == CADMON
        html = pc.level >= MIN_LEVEL ? "31296-01.htm" : "31296-02.html"
      end
    when State::STARTED
      case npc.id
      when CADMON
        if st.memo_state?(11)
          html = "31296-04.html"
        end
      when LEON
        if st.memo_state?(11)
          html = "31256-01.html"
        elsif st.memo_state?(21)
          html = "31256-03.html"
        end
      when WAHKAN
        if st.memo_state?(21) && has_quest_items?(pc, MUNITIONS_BOX)
          html = "31371-01.html"
        end
      end
    when State::COMPLETED
      if npc.id == CADMON
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
