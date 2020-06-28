class Scripts::Q00110_ToThePrimevalIsle < Quest
  # NPCs
  private ANTON = 31338
  private MARQUEZ = 32113
  # Item
  private ANCIENT_BOOK = 8777

  def initialize
    super(110, self.class.simple_name, "To the Primeval Isle")

    add_start_npc(ANTON)
    add_talk_id(ANTON, MARQUEZ)
    register_quest_items(ANCIENT_BOOK)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "31338-1.html"
      st.give_items(ANCIENT_BOOK, 1)
      st.start_quest
    when "32113-2.html", "32113-2a.html"
      st.give_adena(191678, true)
      st.add_exp_and_sp(251602, 25245)
      st.exit_quest(false, true)
    end


    event
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when ANTON
      case st.state
      when State::CREATED
        html = pc.level < 75 ? "31338-0a.htm" : "31338-0b.htm"
      when State::STARTED
        html = "31338-1a.html"
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end

    when MARQUEZ
      if st.cond?(1)
        html = "32113-1.html"
      end
    end


    html || get_no_quest_msg(pc)
  end
end
