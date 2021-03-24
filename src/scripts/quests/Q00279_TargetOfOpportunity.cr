class Scripts::Q00279_TargetOfOpportunity < Quest
  # NPCs
  private JERIAN = 32302
  private MONSTERS = {
    22373,
    22374,
    22375,
    22376
  }
  # Items
  private SEAL_COMPONENTS = {
    15517,
    15518,
    15519,
    15520
  }
  private SEAL_BREAKERS = {
    15515,
    15516
  }

  def initialize
    super(279, self.class.simple_name, "Target of Opportunity")

    add_start_npc(JERIAN)
    add_talk_id(JERIAN)
    add_kill_id(MONSTERS)
    register_quest_items(SEAL_COMPONENTS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end
    if pc.level < 82
      return get_no_quest_msg(pc)
    end

    if event.casecmp?("32302-05.html")
      st.start_quest
      st.set("progress", "1")
    elsif event.casecmp?("32302-08.html") && st.get_int("progress") == 1
      if (0..3).all? { |n| st.has_quest_items?(SEAL_COMPONENTS[n]) }
        st.give_items(SEAL_BREAKERS[0], 1)
        st.give_items(SEAL_BREAKERS[1], 1)
        st.exit_quest(true, true)
      end
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless pl = get_random_party_member(pc, "progress", "1")
      return
    end

    unless idx = MONSTERS.bsearch_index_of(npc.id)
      return
    end

    st = get_quest_state!(pl, false)
    if Rnd.rand(1000) < 311 * Config.rate_quest_drop
      unless st.has_quest_items?(SEAL_COMPONENTS[idx])
        st.give_items(SEAL_COMPONENTS[idx], 1)
        if has_all_except_this?(st, idx)
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if st.state.created?
      html = pc.level >= 82 ? "32302-01.htm" : "32302-02.html"
    elsif st.state.started? && st.get_int("progress") == 1
      if (0..3).all? { |n| st.has_quest_items?(SEAL_COMPONENTS[n]) }
        html = "32302-07.html"
      else
        html = "32302-06.html"
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def has_all_except_this?(st, idx)
    SEAL_COMPONENTS.each do |i|
      if i == idx
        next
      end

      unless st.has_quest_items?(SEAL_COMPONENTS[i])
        return false
      end
    end

    true
  end
end
