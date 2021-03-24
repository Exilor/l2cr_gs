class Scripts::Q00119_LastImperialPrince < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    html = nil
    case event
    when "31453-02.htm", "31453-03.htm", "31453-10.html"
      html = event
    when "31453-04.html"
      st.start_quest
      html = event
    when "31453-11.html"
      if st.cond?(2)
        st.give_adena(150_292, true)
        st.add_exp_and_sp(902_439, 90_067)
        st.exit_quest(false, true)
        html = event
      end
    when "brooch"
      html = st.has_quest_items?(ANTIQUE_BROOCH) ? "32009-02.html" : "32009-03.html"
    when "32009-04.html"
      if st.cond?(1) && st.has_quest_items?(ANTIQUE_BROOCH)
        st.set_cond(2, true)
        html = event
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      if npc.id == NAMELESS_SPIRIT
        html = "31453-06.html"
      end
    when State::CREATED
      if pc.level >= MIN_LEVEL && st.has_quest_items?(ANTIQUE_BROOCH)
        html = "31453-01.htm"
      else
        html = "31453-05.html"
      end
    when State::STARTED
      if npc.id == NAMELESS_SPIRIT
        if st.cond?(1)
          if st.has_quest_items?(ANTIQUE_BROOCH)
            html = "31453-07.html"
          else
            html = "31453-08.html"
            st.exit_quest(true)
          end
        elsif st.cond?(2)
          html = "31453-09.html"
        end
      elsif npc.id == DEVORIN
        if st.cond?(1)
          html = "32009-01.html"
        elsif st.cond?(2)
          html = "32009-05.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
