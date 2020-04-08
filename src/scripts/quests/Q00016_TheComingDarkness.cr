class Scripts::Q00016_TheComingDarkness < Quest
  # NPCs
  private HIERARCH = 31517
  private EVIL_ALTAR_1 = 31512
  private EVIL_ALTAR_2 = 31513
  private EVIL_ALTAR_3 = 31514
  private EVIL_ALTAR_4 = 31515
  private EVIL_ALTAR_5 = 31516
  # Item
  private CRYSTAL_OF_SEAL = 7167

  def initialize
    super(16, self.class.simple_name, "The Coming Darkness")

    add_start_npc(HIERARCH)
    add_talk_id(
      HIERARCH, EVIL_ALTAR_1, EVIL_ALTAR_2, EVIL_ALTAR_3, EVIL_ALTAR_4,
      EVIL_ALTAR_5
    )
    register_quest_items(CRYSTAL_OF_SEAL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    return html unless st = get_quest_state(pc, false)

    cond = st.cond
    case event
    when "31517-02.htm"
      st.start_quest
      st.give_items(CRYSTAL_OF_SEAL, 5)
    when "31512-01.html", "31513-01.html", "31514-01.html", "31515-01.html", "31516-01.html"
      npc_id = event.to_i
      if cond == npc_id - 31511 && st.has_quest_items?(CRYSTAL_OF_SEAL)
        st.take_items(CRYSTAL_OF_SEAL, 1)
        st.set_cond(cond + 1, true)
      end
    else
      # automatically added
    end

    return html
  end

  def on_talk(npc, pc)
    html = get_no_quest_msg(pc)
    st = get_quest_state!(pc)
    st2 = pc.get_quest_state(Q00017_LightAndDarkness.simple_name)

    if st2.nil? || !st2.completed?
      return "31517-04.html"
    end

    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      html = pc.level >= 62 ? "31517-00.htm" : "31517-05.html"
    when State::STARTED
      npc_id = npc.id
      if npc_id == HIERARCH
        if st.cond?(6)
          st.add_exp_and_sp(865187, 69172)
          st.exit_quest(false, true)
          html = "31517-03.html"
        else
          html = "31517-02a.html"
        end
      elsif npc_id - 31511 == st.cond
        html = npc_id.to_s + "-00.html"
      else
        html = npc_id.to_s + "-01.html"
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end