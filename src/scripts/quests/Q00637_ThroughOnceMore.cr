class Scripts::Q00637_ThroughOnceMore < Quest
  private FLAURON = 32010
  private MOBS = {
    21565,
    21566,
    21567
  }
  private VISITOR_MARK = 8064
  private FADED_MARK = 8065
  private NECRO_HEART = 8066
  private MARK = 8067
  private DROP_CHANCE = 90

  def initialize
    super(637, self.class.simple_name, "Through the Gate Once More")

    add_start_npc(FLAURON)
    add_talk_id(FLAURON)
    add_kill_id(MOBS)
    register_quest_items(NECRO_HEART)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if event == "32010-03.htm"
      st.start_quest
    elsif event == "32010-10.htm"
      st.exit_quest(true)
    end

    event
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.state == State::STARTED
      count = st.get_quest_items_count(NECRO_HEART)
      if count < 10
        chance = (Config.rate_quest_drop * DROP_CHANCE).to_i
        num_items = chance // 100
        chance %= 100
        if rand(100) < chance
          num_items += 1
        end
        if num_items > 0
          if count + num_items >= 10
            num_items = 10 - count.to_i
            st.set_cond(2, true)
          else
            st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
          end

          st.give_items(NECRO_HEART, num_items)
        end
      end
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    id = st.state
    if id == State::CREATED
      if pc.level > 72
        if st.has_quest_items?(FADED_MARK)
          return "32010-02.htm"
        end
        if st.has_quest_items?(VISITOR_MARK)
          st.exit_quest(true)
          return "32010-01a.htm"
        end
        if st.has_quest_items?(MARK)
          st.exit_quest(true)
          return "32010-0.htm"
        end
      end
      st.exit_quest(true)
      return "32010-01.htm"
    elsif id == State::STARTED
      if st.cond?(2) && st.get_quest_items_count(NECRO_HEART) == 10
        st.take_items(NECRO_HEART, 10)
        st.take_items(FADED_MARK, 1)
        st.give_items(MARK, 1)
        st.give_items(8273, 10)
        st.exit_quest(true, true)
        return "32010-05.htm"
      end
      return "32010-04.htm"
    end

    get_no_quest_msg(pc)
  end
end
