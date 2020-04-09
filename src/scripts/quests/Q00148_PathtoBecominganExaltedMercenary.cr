class Scripts::Q00148_PathtoBecominganExaltedMercenary < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return html
    end

    if event.casecmp?("exalted-00b.htm")
      st.give_items(ELITE_CERTIFICATE, 1)
    elsif event.casecmp?("exalted-03.htm")
      st.start_quest
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      clan = pc.clan
      if clan && clan.castle_id > 0
        html = "castle.htm"
      elsif st.has_quest_items?(ELITE_CERTIFICATE)
        html = "exalted-01.htm"
      else
        if pc.quest_completed?(Q00147_PathtoBecominganEliteMercenary.simple_name)
          html = "exalted-00a.htm"
        else
          html = "exalted-00.htm"
        end
      end
    when State::STARTED
      if st.cond < 4
        html = "exalted-04.htm"
      elsif st.cond?(4)
        st.take_items(ELITE_CERTIFICATE, -1)
        st.give_items(TOP_ELITE_CERTIFICATE, 1)
        st.exit_quest(false)
        html = "exalted-05.htm"
      end
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
