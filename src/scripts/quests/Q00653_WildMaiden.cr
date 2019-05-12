class Scripts::Q00653_WildMaiden < Quest
  # NPCs
  private GALIBREDO = 30181
  private SUKI = 32013
  # Item
  private SOE = 736
  # Misc
  private MIN_LEVEL = 36

  def initialize
    super(653, self.class.simple_name, "Wild Maiden")

    add_start_npc(SUKI)
    add_talk_id(GALIBREDO, SUKI)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if event == "32013-03.html"
      html = event
    elsif event == "32013-04.htm"
      unless st.has_quest_items?(SOE)
        return "32013-05.htm"
      end
      npc = npc.not_nil!
      st.start_quest
      st.take_items(SOE, 1)
      npc.delete_me
      html = rand(2) == 0 ? event : "32013-04a.htm"
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when SUKI
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "32013-01.htm" : "32013-01a.htm"
      when State::STARTED
        html = "32013-02.htm"
      end
    when GALIBREDO
      if st.started?
        st.give_adena(2553, true)
        st.exit_quest(true, true)
        html = "30181-01.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
