class Quests::Q00148_PathtoBecominganExaltedMercenary < Quest
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
  private ELITE_CERTIFICATE = 13767
  private TOP_ELITE_CERTIFICATE = 13768

  def initialize
    super(148, self.class.simple_name, "Path to Becoming an Exalted Mercenary")

    add_start_npc(MERC)
    add_talk_id(MERC)
  end

  def on_adv_event(event, npc, player)
    return unless player
    htmltext = event
    unless st = get_quest_state(player, false)
      return htmltext
    end

    if event.casecmp?("exalted-00b.htm")
      st.give_items(ELITE_CERTIFICATE, 1)
    elsif event.casecmp?("exalted-03.htm")
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
      elsif st.has_quest_items?(ELITE_CERTIFICATE)
        htmltext = "exalted-01.htm"
      else
        if player.quest_completed?(Q00147_PathtoBecominganEliteMercenary.simple_name)
          htmltext = "exalted-00a.htm"
        else
          htmltext = "exalted-00.htm"
        end
      end
    when State::STARTED
      if st.cond < 4
        htmltext = "exalted-04.htm"
      elsif st.cond?(4)
        st.take_items(ELITE_CERTIFICATE, -1)
        st.give_items(TOP_ELITE_CERTIFICATE, 1)
        st.exit_quest(false)
        htmltext = "exalted-05.htm"
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    end

    htmltext || get_no_quest_msg(player)
  end
end
