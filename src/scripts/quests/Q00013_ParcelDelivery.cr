class Quests::Q00013_ParcelDelivery < Quest
  # NPCs
	private FUNDIN = 31274
	private VULCAN = 31539
	# Item
	private PACKAGE = 7263

  def initialize
    super(13, self.class.simple_name, "Parcel Delivery")

    add_start_npc(FUNDIN)
    add_talk_id(FUNDIN, VULCAN)
    register_quest_items(PACKAGE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "31274-02.html"
      st.start_quest
      st.give_items(PACKAGE, 1)
    when "31539-01.html"
      if st.cond?(1) && st.has_quest_items?(PACKAGE)
        st.give_adena(157834, true)
        st.add_exp_and_sp(589092, 58794)
        st.exit_quest(false, true)
      else
        return "31539-02.html"
      end
    end

    event
  end

  def on_talk(npc, pc)
    htmltext = get_no_quest_msg(pc)
    return htmltext unless st = get_quest_state(pc, true)

    case st.state
    when State::CREATED
      if npc.id == FUNDIN
        htmltext = pc.level >= 74 ? "31274-00.htm" : "31274-01.html"
      end
    when State::STARTED
      if st.cond?(1)
        case npc.id
        when FUNDIN
          htmltext = "31274-02.html"
        when VULCAN
          htmltext = "31539-00.html"
        end
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(pc)
    end

    htmltext
  end
end
