class Quests::Q00019_GoToThePastureland < Quest
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

  def on_adv_event(event, npc, player)
    return unless player
    htmltext = event
    st = get_quest_state(player, false)

    if st.nil?
      return get_no_quest_msg(player)
    end

    if event.casecmp?("31302-02.htm")
      st.start_quest
      st.give_items(VEAL, 1)
    elsif event.casecmp?("31537-02.html")
      if st.has_quest_items?(YOUNG_WILD_BEAST_MEAT)
        st.give_adena(50000, true)
        st.add_exp_and_sp(136766, 12688)
        st.exit_quest(false, true)
        htmltext = "31537-02.html"
      elsif st.has_quest_items?(VEAL)
        st.give_adena(147200, true)
        st.add_exp_and_sp(385040, 75250)
        st.exit_quest(false, true)
        htmltext = "31537-02.html"
      else
        htmltext = "31537-03.html"
      end
    end
    return htmltext
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    if npc.id == VLADIMIR
      case st.state
      when State::CREATED
        if player.level >= 82
          htmltext = "31302-01.htm"
        else
          htmltext = "31302-03.html"
        end
      when State::STARTED
        htmltext = "31302-04.html"
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    elsif npc.id == TUNATUN && st.cond?(1)
      htmltext = "31537-01.html"
    end

    htmltext || get_no_quest_msg(player)
  end
end
