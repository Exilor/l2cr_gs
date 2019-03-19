class Quests::Q00053_LinnaeusSpecialBait < Quest
  # NPCs
  private LINNAEUS = 31577
  private CRIMSON_DRAKE = 20670
  # Items
  private CRIMSON_DRAKE_HEART = 7624
  private FLAMING_FISHING_LURE = 7613

  def initialize
    super(53, self.class.simple_name, "Linnaeus Special Bait")

    add_start_npc(LINNAEUS)
    add_talk_id(LINNAEUS)
    add_kill_id(CRIMSON_DRAKE)
    register_quest_items(CRIMSON_DRAKE_HEART)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end

    htmltext = event

    case event
    when "31577-1.htm"
      st.start_quest
    when "31577-3.htm"
      if st.cond?(2) && st.get_quest_items_count(CRIMSON_DRAKE_HEART) >= 100
        st.give_items(FLAMING_FISHING_LURE, 4)
        st.exit_quest(false, true)
      else
        htmltext = "31577-5.html"
      end
    end

    htmltext
  end

  def on_kill(npc, player, is_summon)
    unless member = get_random_party_member(player, 1)
      return
    end

    st = get_quest_state(member, false).not_nil!

    if st.get_quest_items_count(CRIMSON_DRAKE_HEART) < 100
      chance = 33 * Config.rate_quest_drop
      if Rnd.rand(100) < chance
        st.reward_items(CRIMSON_DRAKE_HEART, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    if st.get_quest_items_count(CRIMSON_DRAKE_HEART) >= 100
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
      htmltext = player.level > 59 ? "31577-0.htm" : "31577-0a.html"
    when State::STARTED
      htmltext = st.cond?(1) ? "31577-4.html" : "31577-2.html"
    end

    htmltext
  end
end
