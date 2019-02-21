class Quests::Q00052_WilliesSpecialBait < Quest
  # NPCs
  private WILLIE = 31574
  private TARLK_BASILISK = 20573
  # Items
  private TARLK_EYE = 7623
  private EARTH_FISHING_LURE = 7612

  def initialize
    super(52, self.class.simple_name, "Willie's Special Bait")

    add_start_npc(WILLIE)
    add_talk_id(WILLIE)
    add_kill_id(TARLK_BASILISK)
    register_quest_items(TARLK_EYE)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end

    htmltext = event
    case event
    when "31574-03.htm"
      st.start_quest
    when "31574-07.html"
      if st.cond?(2) && st.get_quest_items_count(TARLK_EYE) >= 100
        htmltext = "31574-06.htm"
        st.give_items(EARTH_FISHING_LURE, 4)
        st.exit_quest(false, true)
      end
    end

    htmltext
  end

  def on_kill(npc, player, is_summon)
    unless member = get_random_party_member(player, 1)
      return
    end

    st = get_quest_state(member, false).not_nil!
    if st.get_quest_items_count(TARLK_EYE) < 100
      chance = 33 * Config.rate_quest_drop
      if Rnd.rand(100) < chance
        st.reward_items(TARLK_EYE, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    if st.get_quest_items_count(TARLK_EYE) >= 100
      st.set_cond(2, true)
    end

    super
  end

  def on_talk(npc, player)
    htmltext = get_no_quest_msg(player)
    st = get_quest_state!(player)
    case st.state
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    when State::CREATED
      htmltext = player.level >= 48 ? "31574-01.htm" : "31574-02.html"
    when State::STARTED
      htmltext = st.cond?(1) ? "31574-05.html" : "31574-04.html"
    end

    htmltext
  end
end
