class Quests::Q00147_PathtoBecominganEliteMercenary < Quest
  # NPCs
  private MERC = {
    36481,
    36482,
    36483,
    36484,
    36485,
    36486,
    36487,
    36488,
    36489
  }
  # Items
  private ORDINARY_CERTIFICATE = 13766
  private ELITE_CERTIFICATE = 13767

  def initialize
    super(147, self.class.simple_name, "Path to Becoming an Elite Mercenary")

    add_start_npc(MERC)
    add_talk_id(MERC)
  end

  def on_adv_event(event, npc, player)
    return unless player
    htmltext = event
    unless st = get_quest_state(player, false)
      return htmltext
    end

    if event.casecmp?("elite-02.htm")
      if st.has_quest_items?(ORDINARY_CERTIFICATE)
        return "elite-02a.htm"
      end
      st.give_items(ORDINARY_CERTIFICATE, 1)
    elsif event.casecmp?("elite-04.htm")
      st.start_quest
    end

    htmltext
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::CREATED
      clan = player.clan?
      if clan && clan.castle_id > 0
        htmltext = "castle.htm"
      else
        htmltext = "elite-01.htm"
      end
    when State::STARTED
      if st.cond < 4
        htmltext = "elite-05.htm"
      elsif st.cond?(4)
        st.take_items(ORDINARY_CERTIFICATE, -1)
        st.give_items(ELITE_CERTIFICATE, 1)
        st.exit_quest(false)
        htmltext = "elite-06.htm"
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    end

    htmltext || get_no_quest_msg(player)
  end
end
