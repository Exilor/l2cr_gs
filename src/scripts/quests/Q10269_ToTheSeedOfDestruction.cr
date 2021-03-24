class Scripts::Q10269_ToTheSeedOfDestruction < Quest
  # NPCs
  private KEUCEREUS = 32548
  private ALLENOS = 32526
  # Item
  private INTRODUCTION = 13812

  def initialize
    super(10269, self.class.simple_name, "To the Seed of Destruction")

    add_start_npc(KEUCEREUS)
    add_talk_id(KEUCEREUS, ALLENOS)
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

    when ALLENOS
      case st.state
      when State::STARTED
        html = "32526-01.html"
        st.give_adena(29174, true)
        st.add_exp_and_sp(176121, 7671)
        st.exit_quest(false, true)
      when State::COMPLETED
        html = "32526-02.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
