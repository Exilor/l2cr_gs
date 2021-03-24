class Scripts::Q10268_ToTheSeedOfInfinity < Quest
  # NPCs
  private KEUCEREUS = 32548
  private TEPIOS = 32603
  # Item
  private INTRODUCTION = 13811

  def initialize
    super(10268, self.class.simple_name, "To the Seed of Infinity")

    add_start_npc(KEUCEREUS)
    add_talk_id(KEUCEREUS, TEPIOS)
    register_quest_items(INTRODUCTION)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    if event == "32548-05.html"
      st.start_quest
      st.give_items(INTRODUCTION, 1)
    end

    event
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when KEUCEREUS
      case st.state
      when State::CREATED
        html = pc.level < 75 ? "32548-00.html" : "32548-01.htm"
      when State::STARTED
        html = "32548-06.html"
      when State::COMPLETED
        html = "32548-0a.html"
      end
    when TEPIOS
      case st.state
      when State::STARTED
        html = "32530-01.html"
        st.give_adena(16_671, true)
        st.add_exp_and_sp(100_640, 10_098)
        st.exit_quest(false, true)
      when State::COMPLETED
        html = "32530-02.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
