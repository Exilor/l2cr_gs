class Scripts::Q00053_LinnaeusSpecialBait < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    html = event

    case event
    when "31577-1.htm"
      st.start_quest
    when "31577-3.htm"
      if st.cond?(2) && st.get_quest_items_count(CRIMSON_DRAKE_HEART) >= 100
        st.give_items(FLAMING_FISHING_LURE, 4)
        st.exit_quest(false, true)
      else
        html = "31577-5.html"
      end
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 1)
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

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      html = pc.level > 59 ? "31577-0.htm" : "31577-0a.html"
    when State::STARTED
      html = st.cond?(1) ? "31577-4.html" : "31577-2.html"
    end

    html || get_no_quest_msg(pc)
  end
end
