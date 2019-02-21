class Quests::Q00051_OFullesSpecialBait < Quest
  # NPCs
  private OFULLE = 31572
  private FETTERED_SOUL = 20552
  # Items
  private LOST_BAIT = 7622
  private ICY_AIR_LURE = 7611

  def initialize
    super(51, self.class.simple_name, "O'Fulle's Special Bait")

    add_start_npc(OFULLE)
    add_talk_id(OFULLE)
    add_kill_id(FETTERED_SOUL)
    register_quest_items(LOST_BAIT)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end

    htmltext = event
    case event
    when "31572-03.htm"
      st.start_quest
    when "31572-07.html"
      if st.cond?(2) && st.get_quest_items_count(LOST_BAIT) >= 100
        htmltext = "31572-06.htm"
        st.give_items(ICY_AIR_LURE, 4)
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
    if st.get_quest_items_count(LOST_BAIT) < 100
      chance = 33 * Config.rate_quest_drop
      if Rnd.rand(100) < chance
        st.reward_items(LOST_BAIT, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    if st.get_quest_items_count(LOST_BAIT) >= 100
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
      htmltext = player.level >= 36 ? "31572-01.htm" : "31572-02.html"
    when State::STARTED
      htmltext = st.cond?(1) ? "31572-05.html" : "31572-04.html"
    end

    htmltext
  end
end
