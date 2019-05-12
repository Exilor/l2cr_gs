class Scripts::Q00122_OminousNews < Quest
  # NPCs
  private MOIRA = 31979
  private KARUDA = 32017

  def initialize
    super(122, self.class.simple_name, "Ominous News")

    add_start_npc(MOIRA)
    add_talk_id(MOIRA, KARUDA)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "31979-02.htm"
      st.start_quest
    when "32017-02.html"
      st.give_adena(8923, true)
      st.add_exp_and_sp(45151, 2310)
      st.exit_quest(false, true)
    end

    event
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when MOIRA
      case st.state
      when State::CREATED
        html = pc.level >= 20 ? "31979-01.htm" : "31979-00.htm"
      when State::STARTED
        html = "31979-03.html"
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when KARUDA
      if st.started?
        html = "32017-01.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
