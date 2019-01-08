class Quests::Q00172_NewHorizons < Quest
  # NPCs
  private ZENYA = 32140
  private RAGARA = 32163

  # Items
  private SCROLL_OF_ESCAPE_GIRAN = 7559
  private MARK_OF_TRAVELER = 7570

  # Misc
  private MIN_LEVEL = 3

  def initialize
    super(172, self.class.simple_name, "New Horizons")

    add_start_npc(ZENYA)
    add_talk_id(ZENYA, RAGARA)
  end

  def on_adv_event(event, npc, player)
    return unless player
    st = get_quest_state(player, false)
    if st.nil?
      return
    end

    htmltext = event
    case event
    when "32140-04.htm"
      st.start_quest
    when "32163-02.html"
      st.give_items(SCROLL_OF_ESCAPE_GIRAN, 1)
      st.give_items(MARK_OF_TRAVELER, 1)
      st.exit_quest(false, true)
    else
      return
    end

    htmltext
  end

  def on_talk(npc, player)
    htmltext = get_no_quest_msg(player)
    st = get_quest_state(player, true)
    return htmltext unless st

    case npc.id
    when ZENYA
      case st.state
      when State::CREATED
        htmltext = player.race.kamael? ? player.level >= MIN_LEVEL ? "32140-01.htm" : "32140-02.htm" : "32140-03.htm"
      when State::STARTED
        htmltext = "32140-05.html"
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    when RAGARA
      if st.started?
        htmltext = "32163-01.html"
      end
    end

    htmltext
  end
end
