class Quests::Q00122_OminousNews < Quest
  # NPCs
  private MOIRA = 31979
  private KARUDA = 32017

  def initialize
    super(122, self.class.simple_name, "Ominous News")

    add_start_npc(MOIRA)
    add_talk_id(MOIRA, KARUDA)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
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

  def on_talk(npc, player)
    st = get_quest_state!(player)
    case npc.id
    when MOIRA
      case st.state
      when State::CREATED
        htmltext = player.level >= 20 ? "31979-01.htm" : "31979-00.htm"
      when State::STARTED
        htmltext = "31979-03.html"
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    when KARUDA
      if st.started?
        htmltext = "32017-01.html"
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
