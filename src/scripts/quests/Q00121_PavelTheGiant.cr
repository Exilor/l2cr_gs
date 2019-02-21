class Quests::Q00121_PavelTheGiant < Quest
  # NPCs
  private NEWYEAR = 31961
  private YUMI = 32041

  def initialize
    super(121, self.class.simple_name, "Pavel the Giant")

    add_start_npc(NEWYEAR)
    add_talk_id(NEWYEAR, YUMI)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end

    case event
    when "31961-02.htm"
      st.start_quest
    when "32041-02.html"
      st.add_exp_and_sp(346320, 26069)
      st.exit_quest(false, true)
    end

    event
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    case npc.id
    when NEWYEAR
      case st.state
      when State::CREATED
        htmltext = player.level >= 70 ? "31961-01.htm" : "31961-00.htm"
      when State::STARTED
        htmltext = "31961-03.html"
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    when YUMI
      if st.started?
        htmltext = "32041-01.html"
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
