class Scripts::Q00019_GoToThePastureland < Quest
  # NPCs
  private VLADIMIR = 31302
  private TUNATUN = 31537
  # Items
  private VEAL = 15532
  private YOUNG_WILD_BEAST_MEAT = 7547

  def initialize
    super(19, self.class.simple_name, "Go to the Pastureland")

    add_start_npc(VLADIMIR)
    add_talk_id(VLADIMIR, TUNATUN)
    register_quest_items(VEAL, YOUNG_WILD_BEAST_MEAT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    if event.casecmp?("31302-02.htm")
      st.start_quest
      st.give_items(VEAL, 1)
    elsif event.casecmp?("31537-02.html")
      if st.has_quest_items?(YOUNG_WILD_BEAST_MEAT)
        st.give_adena(50000, true)
        st.add_exp_and_sp(136766, 12688)
        st.exit_quest(false, true)
        html = "31537-02.html"
      elsif st.has_quest_items?(VEAL)
        st.give_adena(147200, true)
        st.add_exp_and_sp(385040, 75250)
        st.exit_quest(false, true)
        html = "31537-02.html"
      else
        html = "31537-03.html"
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if npc.id == VLADIMIR
      case st.state
      when State::CREATED
        if pc.level >= 82
          html = "31302-01.htm"
        else
          html = "31302-03.html"
        end
      when State::STARTED
        html = "31302-04.html"
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end
    elsif npc.id == TUNATUN && st.cond?(1)
      html = "31537-01.html"
    end

    html || get_no_quest_msg(pc)
  end
end
