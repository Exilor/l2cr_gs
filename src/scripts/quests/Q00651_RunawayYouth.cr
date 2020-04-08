class Scripts::Q00651_RunawayYouth < Quest
  # NPCs
  private BATIDAE = 31989
  private IVAN = 32014
  # Item
  private SOE = 736
  # Misc
  private MIN_LEVEL = 26

  def initialize
    super(651, self.class.simple_name, "Runaway Youth")

    add_start_npc(IVAN)
    add_talk_id(BATIDAE, IVAN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if event == "32014-03.html"
      html = event
    elsif event == "32014-04.htm"
      unless st.has_quest_items?(SOE)
        return "32014-05.htm"
      end
      npc = npc.not_nil!
      st.start_quest
      st.take_items(SOE, 1)
      npc.delete_me
      html = event
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when IVAN
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "32014-01.htm" : "32014-01a.htm"
      when State::STARTED
        html = "32014-02.html"
      else
        # automatically added
      end

    when BATIDAE
      if st.started?
        st.give_adena(2883, true)
        st.exit_quest(true, true)
        html = "31989-01.html"
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end