class Quests::Q00146_TheZeroHour < Quest
  # NPCs
  private KAHMAN = 31554
  private QUEEN_SHYEED = 25671
  # Item
  private KAHMANS_SUPPLY_BOX = 14849
  private FANG = 14859

  def initialize
    super(146, self.class.simple_name, "The Zero Hour")

    add_start_npc(KAHMAN)
    add_talk_id(KAHMAN)
    add_kill_id(QUEEN_SHYEED)
    register_quest_items(FANG)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end

    if event.casecmp?("31554-03.htm")
      st.start_quest
    end

    event
  end

  def on_kill(npc, killer, is_summon)
    if member = get_random_party_member(killer, 1)
      st = get_quest_state(member, false).not_nil!
      unless st.has_quest_items?(FANG)
        st.give_items(FANG, 1)
        st.set_cond(2, true)
      end
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::CREATED
      if player.level < 81
        htmltext = "31554-02.htm"
      else
        if player.quest_completed?(Q00109_InSearchOfTheNest.simple_name)
          htmltext = "31554-01a.htm"
        else
          htmltet = "31554-04.html"
        end
      end
    when State::STARTED
      if st.cond?(1)
        htmltext = "31554-06.html"
      else
        st.give_items(KAHMANS_SUPPLY_BOX, 1)
        st.add_exp_and_sp(154616, 12500)
        st.exit_quest(false, true)
        htmltext = "31554-05.html"
      end
    when State::COMPLETED
      htmltext = "31554-01b.htm"
    end

    htmltext || get_no_quest_msg(player)
  end
end
