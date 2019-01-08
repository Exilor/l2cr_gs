class Quests::Q00014_WhereaboutsOfTheArchaeologist < Quest
  # NPCs
  private LIESEL = 31263
  private GHOST_OF_ADVENTURER = 31538
  # Item
  private LETTER = 7253

  def initialize
    super(14, self.class.simple_name, "Whereabouts of the Archaeologist")

    add_start_npc(LIESEL)
    add_talk_id(LIESEL, GHOST_OF_ADVENTURER)
    register_quest_items(LETTER)
  end

  def on_adv_event(event, npc, player)
    return unless player
    htmltext = event
    st = get_quest_state(player, false)
    if st.nil?
      return htmltext
    end

    case event
    when "31263-02.html"
      st.start_quest
      st.give_items(LETTER, 1)
    when "31538-01.html"
      if st.cond?(1) && st.has_quest_items?(LETTER)
        st.give_adena(136928, true)
        st.add_exp_and_sp(325881, 32524)
        st.exit_quest(false, true)
      else
        htmltext = "31538-02.html"
      end
    end
    return htmltext
  end

  def on_talk(npc, player)
    htmltext = get_no_quest_msg(player)
    st = get_quest_state(player, true)
    if st.nil?
      return htmltext
    end

    npcId = npc.id
    case st.state
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    when State::CREATED
      if npcId == LIESEL
        htmltext = (player.level < 74) ? "31263-01.html" : "31263-00.htm"
      end
    when State::STARTED
      if st.cond?(1)
        case npcId
        when LIESEL
          htmltext = "31263-02.html"
        when GHOST_OF_ADVENTURER
          htmltext = "31538-00.html"
        end
      end
    end

    return htmltext
  end
end
