class Scripts::Q00553_OlympiadUndefeated < Quest
  # NPC
  private MANAGER = 31688
  # Items
  private WIN_CONF_2 = 17244
  private WIN_CONF_5 = 17245
  private WIN_CONF_10 = 17246
  private OLY_CHEST = 17169
  private MEDAL_OF_GLORY = 21874

  def initialize
    super(553, self.class.simple_name, "Olympiad Undefeated")

    add_start_npc(MANAGER)
    add_talk_id(MANAGER)
    register_quest_items(WIN_CONF_2, WIN_CONF_5, WIN_CONF_10)
    add_olympiad_match_finish_id
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end
    html = event

    if event.casecmp?("31688-03.html")
      st.start_quest
    elsif event.casecmp?("31688-04.html")
      count = st.get_quest_items_count(WIN_CONF_2)
      count += st.get_quest_items_count(WIN_CONF_5)

      if count > 0
        st.give_items(OLY_CHEST, count)
        if count == 2
          st.give_items(MEDAL_OF_GLORY, 3)
        end
        st.exit_quest(QuestType::DAILY, true)
      else
        html = get_no_quest_msg(pc)
      end
    end

    html
  end

  def on_olympiad_match_finish(winner, loser, type)
    if winner
      unless player = winner.player?
        return
      end

      st = get_quest_state(player, false)
      if st && st.started? && st.cond?(1)
        matches = st.get_int("undefeatable") + 1
        st.set("undefeatable", matches.to_s)
        case matches
        when 2
          unless st.has_quest_items?(WIN_CONF_2)
            st.give_items(WIN_CONF_2, 1)
          end
        when 5
          unless st.has_quest_items?(WIN_CONF_5)
            st.give_items(WIN_CONF_5, 1)
          end
        when 10
          unless st.has_quest_items?(WIN_CONF_10)
            st.give_items(WIN_CONF_10, 1)
            st.set_cond(2)
          end
        end
      end
    end

    if loser
      unless player = loser.player?
        return
      end

      st = get_quest_state(player, false)
      if st && st.started? && st.cond?(1)
        st.unset("undefeatable")
        st.take_items(WIN_CONF_2, -1)
        st.take_items(WIN_CONF_5, -1)
        st.take_items(WIN_CONF_10, -1)
      end
    end
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if pc.level < 75 || !pc.noble?
      html = "31688-00.htm"
    elsif st.created?
      html = "31688-01.htm"
    elsif st.completed?
      if st.now_available?
        st.state = State::CREATED
        html = pc.level < 75 || !pc.noble? ? "31688-00.htm" : "31688-01.htm"
      else
        html = "31688-05.html"
      end
    else
      count = st.get_quest_items_count(WIN_CONF_2)
      count += st.get_quest_items_count(WIN_CONF_5)
      count += st.get_quest_items_count(WIN_CONF_10)

      if count == 3 && st.cond?(2)
        st.give_items(OLY_CHEST, 4)
        st.give_items(MEDAL_OF_GLORY, 5)
        st.exit_quest(QuestType::DAILY, true)
        html = "31688-04.html"
      else
        html = "31688-w#{count}.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end

