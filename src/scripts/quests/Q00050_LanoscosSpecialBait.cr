class Scripts::Q00050_LanoscosSpecialBait < Quest
  # NPCs
  private LANOSCO = 31570
  private SINGING_WIND = 21026
  # Items
  private ESSENCE_OF_WIND = 7621
  private WIND_FISHING_LURE = 7610

  def initialize
    super(50, self.class.simple_name, "Lanosco's Special Bait")

    add_start_npc(LANOSCO)
    add_talk_id(LANOSCO)
    add_kill_id(SINGING_WIND)
    register_quest_items(ESSENCE_OF_WIND)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    html = event

    case event
    when "31570-03.htm"
      st.start_quest
    when "31570-07.html"
      if st.cond?(2) && st.get_quest_items_count(ESSENCE_OF_WIND) >= 100
        html = "31570-06.htm"
        st.give_items(WIND_FISHING_LURE, 4)
        st.exit_quest(false, true)
      end
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 1)
      return
    end

    st = get_quest_state(member, false).not_nil!

    if st.get_quest_items_count(ESSENCE_OF_WIND) < 100
      chance = 33 * Config.rate_quest_drop
      if Rnd.rand(100) < chance
        st.reward_items(ESSENCE_OF_WIND, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    if st.get_quest_items_count(ESSENCE_OF_WIND) >= 100
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
      html = pc.level >= 27 ? "31570-01.htm" : "31570-02.html"
    when State::STARTED
      html = st.cond?(1) ? "31570-05.html" : "31570-04.html"
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end