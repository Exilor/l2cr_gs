class Scripts::Q00051_OFullesSpecialBait < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    html = event
    case event
    when "31572-03.htm"
      st.start_quest
    when "31572-07.html"
      if st.cond?(2) && st.get_quest_items_count(LOST_BAIT) >= 100
        html = "31572-06.htm"
        st.give_items(ICY_AIR_LURE, 4)
        st.exit_quest(false, true)
      end
    else
      # [automatically added else]
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 1)
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

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      html = pc.level >= 36 ? "31572-01.htm" : "31572-02.html"
    when State::STARTED
      html = st.cond?(1) ? "31572-05.html" : "31572-04.html"
    else
      # [automatically added else]
    end

    html || get_no_quest_msg(pc)
  end
end
