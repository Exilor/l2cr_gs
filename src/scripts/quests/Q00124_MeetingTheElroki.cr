class Quests::Q00124_MeetingTheElroki < Quest
  # NPCs
  private MARQUEZ = 32113
  private MUSHIKA = 32114
  private ASAMAH = 32115
  private KARAKAWEI = 32117
  private MANTARASA = 32118
  # Item
  private MANTARASA_EGG = 8778

  def initialize
    super(124, self.class.simple_name, "Meeting the Elroki")

    add_start_npc(MARQUEZ)
    add_talk_id(MARQUEZ, MUSHIKA, ASAMAH, KARAKAWEI, MANTARASA)
    register_quest_items(MANTARASA_EGG)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end

    case event
    when "32113-03.html"
      st.start_quest
    when "32113-04.html"
      if st.cond?(1)
        st.set_cond(2, true)
      end
    when "32114-04.html"
      if st.cond?(2)
        st.set_cond(3, true)
      end
    when "32115-06.html"
      if st.cond?(3)
        st.set_cond(4, true)
      end
    when "32117-05.html"
      if st.cond?(4)
        st.set_cond(5, true)
      end
    when "32118-04.html"
      if st.cond?(5)
        st.give_items(MANTARASA_EGG, 1)
        st.set_cond(6, true)
      end
    end

    event
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    case npc.id
    when MARQUEZ
      case st.state
      when State::CREATED
        htmltext = player.level < 75 ? "32113-01a.htm" : "32113-01.htm"
      when State::STARTED
        case st.get_int("cond")
        when 1
          htmltext = "32113-05.html"
        when 2
          htmltext = "32113-06.html"
        when 3..5
          htmltext = "32113-07.html"
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    when MUSHIKA
      if st.started?
        case st.get_int("cond")
        when 1
          htmltext = "32114-01.html"
        when 2
          htmltext = "32114-02.html"
        else
          htmltext = "32114-03.html"
        end
      end
    when ASAMAH
      if st.started?
        case st.cond
        when 1, 2
          htmltext = "32115-01.html"
        when 3
          htmltext = "32115-02.html"
        when 4
          htmltext = "32115-07.html"
        when 5
          htmltext = "32115-08.html"
        when 6
          if st.has_quest_items?(MANTARASA_EGG)
            htmltext = "32115-09.html"
            st.give_adena(100013, true)
            st.add_exp_and_sp(301922, 30294)
            st.exit_quest(false, true)
          end
        end
      end
    when KARAKAWEI
      if st.started?
        case st.cond
        when 1..3
          htmltext = "32117-01.html"
        when 4
          htmltext = "32117-02.html"
        when 5
          htmltext = "32117-07.html"
        when 6
          htmltext = "32117-06.html"
        end
      end
    when MANTARASA
      if st.started?
        case st.cond
        when 1..4
          htmltext = "32118-01.html"
        when 5
          htmltext = "32118-03.html"
        when 6
          htmltext = "32118-02.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
