class Quests::Q00113_StatusOfTheBeaconTower < Quest
  # NPCs
  private MOIRA = 31979
  private TORRANT = 32016
  # Items
  private FLAME_BOX = 14860
  private FIRE_BOX = 8086

  def initialize
    super(113, self.class.simple_name, "Status of the Beacon Tower")

    add_start_npc(MOIRA)
    add_talk_id(MOIRA, TORRANT)
    register_quest_items(FIRE_BOX, FLAME_BOX)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    htmltext = event
    case event
    when "31979-02.htm"
      st.start_quest
      st.give_items(FLAME_BOX, 1)
    when "32016-02.html"
      if st.has_quest_items?(FIRE_BOX)
        st.give_adena(21578, true)
        st.add_exp_and_sp(76665, 5333)
      else
        st.give_adena(154800, true)
        st.add_exp_and_sp(619300, 44200)
      end
      st.exit_quest(false, true)
    else
      htmltext = nil
    end

    htmltext
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case npc.id
    when MOIRA
      case st.state
      when State::CREATED
        htmltext = player.level >= 80 ? "31979-01.htm" : "31979-00.htm"
      when State::STARTED
        htmltext = "31979-03.html"
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    when TORRANT
      if st.started?
        htmltext = "32016-01.html"
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
