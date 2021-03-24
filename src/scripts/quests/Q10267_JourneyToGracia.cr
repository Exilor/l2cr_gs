class Scripts::Q10267_JourneyToGracia < Quest
  # NPCs
  private ORVEN = 30857
  private KEUCEREUS = 32548
  private PAPIKU = 32564
  # Item
  private LETTER = 13810

  def initialize
    super(10267, self.class.simple_name, "Journey to Gracia")

    add_start_npc(ORVEN)
    add_talk_id(ORVEN, KEUCEREUS, PAPIKU)
    register_quest_items(LETTER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "30857-06.html"
      st.start_quest
      st.give_items(LETTER, 1)
    when "32564-02.html"
      st.set_cond(2, true)
    when "32548-02.html"
      st.give_adena(92_500, true)
      st.add_exp_and_sp(75_480, 7570)
      st.exit_quest(false, true)
    end

    event
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when ORVEN
      case st.state
      when State::CREATED
        html = pc.level < 75 ? "30857-00.html" : "30857-01.htm"
      when State::STARTED
        html = "30857-07.html"
      when State::COMPLETED
        html = "30857-0a.html"
      end

    when PAPIKU
      if st.started?
        html = st.cond?(1) ? "32564-01.html" : "32564-03.html"
      end
    when KEUCEREUS
      if st.started? && st.cond?(2)
        html = "32548-01.html"
      elsif st.completed?
        html = "32548-03.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
