class Scripts::Q00251_NoSecrets < Quest
  private PINAPS = 30201
  private DIARY = 15508
  private TABLE = 15509

  private MOBS = {
    22783,
    22785,
    22780,
    22782,
    22784
  }

  private MOBS2 = {
    22775,
    22776,
    22778
  }

  def initialize
    super(251, self.class.simple_name, "No Secrets")

    add_start_npc(PINAPS)
    add_talk_id(PINAPS)
    add_kill_id(MOBS)
    add_kill_id(MOBS2)
    register_quest_items(DIARY, TABLE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    if event == "30201-03.htm"
      st.start_quest
    end

    event
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.started? && st.cond?(1)
      npc_id = npc.id

      if MOBS.includes?(npc_id) && Rnd.rand(100) < 10 && st.get_quest_items_count(DIARY) < 10
        st.give_items(DIARY, 1)
        if st.get_quest_items_count(DIARY) >= 10 && st.get_quest_items_count(TABLE) >= 5
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      elsif MOBS2.includes?(npc_id) && Rnd.rand(100) < 5 && st.get_quest_items_count(TABLE) < 5
        st.give_items(TABLE, 1)
        if st.get_quest_items_count(DIARY) >= 10 && st.get_quest_items_count(TABLE) >= 5
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::CREATED
      html = pc.level > 81 ? "30201-01.htm" : "30201-00.htm"
    when State::STARTED
      if st.cond?(1)
        html = "30201-05.htm"
      elsif st.cond?(2) && st.get_quest_items_count(DIARY) >= 10
        if st.get_quest_items_count(TABLE) >= 5
          html = "30201-04.htm"
          st.give_adena(313355, true)
          st.add_exp_and_sp(56787, 160578)
          st.exit_quest(false, true)
        end
      end
    when State::COMPLETED
      html = "30201-06.htm"
    end

    html || get_no_quest_msg(pc)
  end
end
