class Quests::Q00119_LastImperialPrince < Quest
  # NPCs
  private NAMELESS_SPIRIT = 31453
  private DEVORIN = 32009
  # Item
  private ANTIQUE_BROOCH = 7262
  # Misc
  private MIN_LEVEL = 74

  def initialize
    super(119, self.class.simple_name, "Last Imperial Prince")

    add_start_npc(NAMELESS_SPIRIT)
    add_talk_id(NAMELESS_SPIRIT, DEVORIN)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    htmltext = nil
    case event
    when "31453-02.htm", "31453-03.htm", "31453-10.html"
      htmltext = event
    when "31453-04.html"
      st.start_quest
      htmltext = event
    when "31453-11.html"
      if st.cond?(2)
        st.give_adena(150292, true)
        st.add_exp_and_sp(902439, 90067)
        st.exit_quest(false, true)
        htmltext = event
      end
    when "brooch"
      htmltext = st.has_quest_items?(ANTIQUE_BROOCH) ? "32009-02.html" : "32009-03.html"
    when "32009-04.html"
      if st.cond?(1) && st.has_quest_items?(ANTIQUE_BROOCH)
        st.set_cond(2, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::COMPLETED
      if npc.id == NAMELESS_SPIRIT
        htmltext = "31453-06.html"
      end
    when State::CREATED
      if player.level >= MIN_LEVEL && st.has_quest_items?(ANTIQUE_BROOCH)
        htmltext = "31453-01.htm"
      else
        htmltext = "31453-05.html"
      end
    when State::STARTED
      if npc.id == NAMELESS_SPIRIT
        if st.cond?(1)
          if st.has_quest_items?(ANTIQUE_BROOCH)
            htmltext = "31453-07.html"
          else
            htmltext = "31453-08.html"
            st.exit_quest(true)
          end
        elsif st.cond?(2)
          htmltext = "31453-09.html"
        end
      elsif npc.id == DEVORIN
        if st.cond?(1)
          htmltext = "32009-01.html"
        elsif st.cond?(2)
          htmltext = "32009-05.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
