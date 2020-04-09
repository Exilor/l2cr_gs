class Scripts::Q00121_PavelTheGiant < Quest
  # NPCs
  private NEWYEAR = 31961
  private YUMI = 32041

  def initialize
    super(121, self.class.simple_name, "Pavel the Giant")

    add_start_npc(NEWYEAR)
    add_talk_id(NEWYEAR, YUMI)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "31961-02.htm"
      st.start_quest
    when "32041-02.html"
      st.add_exp_and_sp(346320, 26069)
      st.exit_quest(false, true)
    else
      # [automatically added else]
    end


    event
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when NEWYEAR
      case st.state
      when State::CREATED
        html = pc.level >= 70 ? "31961-01.htm" : "31961-00.htm"
      when State::STARTED
        html = "31961-03.html"
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end

    when YUMI
      if st.started?
        html = "32041-01.html"
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
