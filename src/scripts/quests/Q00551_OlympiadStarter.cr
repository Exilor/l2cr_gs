class Scripts::Q00551_OlympiadStarter < Quest
  private MANAGER = 31688

  private CERT_3 = 17238
  private CERT_5 = 17239
  private CERT_10 = 17240

  private OLY_CHEST = 17169
  private MEDAL_OF_GLORY = 21874

  def initialize
    super(551, self.class.simple_name, "Olympiad Starter")

    add_start_npc(MANAGER)
    add_talk_id(MANAGER)
    register_quest_items(CERT_3, CERT_5, CERT_10)
    add_olympiad_match_finish_id
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    html = event

    case event
    when "31688-03.html"
      st.start_quest
      st.memo_state = 1
      st.set_memo_state_ex(1, 0)
    when "31688-04.html"
      if st.get_quest_items_count(CERT_3) + st.get_quest_items_count(CERT_5) > 0
        if st.has_quest_items?(CERT_3)
          st.give_items(OLY_CHEST, 1)
          st.take_items(CERT_3, -1)
        end

        if st.has_quest_items?(CERT_5)
          st.give_items(OLY_CHEST, 1)
          st.give_items(MEDAL_OF_GLORY, 3)
          st.take_items(CERT_5, -1)
        end

        st.exit_quest(QuestType::DAILY, true)
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_olympiad_lose(loser, type)
    if loser
      st = get_quest_state(loser, false)
      if st && st.started? && st.memo_state?(1)
        memo_state_ex = st.get_memo_state_ex(1)
        if memo_state_ex == 9
          st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 1)
          st.memo_state = 2
          st.set_cond(2, true)
          st.give_items(CERT_10, 1)
        elsif memo_state_ex < 9
          if st.memo_state_ex?(1, 2)
            st.give_items(CERT_3, 1)
          elsif st.memo_state_ex?(1, 4)
            st.give_items(CERT_5, 1)
          end

          st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end
  end

  def on_olympiad_match_finish(winner, loser, type)
    if winner
      unless player = winner.player?
        return
      end
      st = get_quest_state(player, false)
      if st && st.started? && st.memo_state?(1)
        memo_state_ex = st.get_memo_state_ex(1)
        if memo_state_ex == 9
          st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 1)
          st.memo_state = 2
          st.set_cond(2, true)
          st.give_items(CERT_10, 1)
        elsif memo_state_ex < 9
          if st.memo_state_ex?(1, 2)
            st.give_items(CERT_3, 1)
          elsif st.memo_state_ex?(1, 4)
            st.give_items(CERT_5, 1)
          end

          st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    if loser
      unless player = loser.player?
        return
      end
      st = get_quest_state(player, false)
      if st && st.started? && st.memo_state?(1)
        memo_state_ex = st.get_memo_state_ex(1)
        if memo_state_ex == 9
          st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 1)
          st.memo_state = 2
          st.set_cond(2, true)
          st.give_items(CERT_10, 1)
        elsif memo_state_ex < 9
          if st.memo_state_ex?(1, 2)
            st.give_items(CERT_3, 1)
          elsif st.memo_state_ex?(1, 4)
            st.give_items(CERT_5, 1)
          end

          st.set_memo_state_ex(1, st.get_memo_state_ex(1) + 1)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
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
        if pc.level < 75 || !pc.noble?
          html = "31688-00.htm"
        else
          html = "31688-01.htm"
        end
      else
        html = "31688-05.html"
      end
    elsif st.started?
      if st.memo_state?(1)
        count = st.get_quest_items_count(CERT_3)
        count &+= st.get_quest_items_count(CERT_5)
        count &+= st.get_quest_items_count(CERT_10)

        if count > 0
          html = "31688-07.html"
        else
          html = "31688-06.html"
        end
      elsif st.memo_state?(2)
        st.give_items(OLY_CHEST, 4)
        st.give_items(MEDAL_OF_GLORY, 5)
        st.exit_quest(QuestType::DAILY, true)
        html = "31688-04.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
