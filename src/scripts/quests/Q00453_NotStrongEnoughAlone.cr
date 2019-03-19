class Quests::Q00453_NotStrongEnoughAlone < Quest
  # NPC
  private KLEMIS = 32734
  private MONSTER1 = {
    22746,
    22747,
    22748,
    22749,
    22750,
    22751,
    22752,
    22753
  }
  private MONSTER2 = {
    22754,
    22755,
    22756,
    22757,
    22758,
    22759
  }
  private MONSTER3 = {
    22760,
    22761,
    22762,
    22763,
    22764,
    22765
  }

  # Reward
  private REWARD = {
    {
      15815,
      15816,
      15817,
      15818,
      15819,
      15820,
      15821,
      15822,
      15823,
      15824,
      15825
    },
    {
      15634,
      15635,
      15636,
      15637,
      15638,
      15639,
      15640,
      15641,
      15642,
      15643,
      15644
    }
  }

  def initialize
    super(453, self.class.simple_name, "Not Strong Enought Alone")

    add_start_npc(KLEMIS)
    add_talk_id(KLEMIS)
    add_kill_id(MONSTER1)
    add_kill_id(MONSTER2)
    add_kill_id(MONSTER3)
  end

  private def increase_kill(pc, npc)
    return unless pc && npc
    unless st = get_quest_state(pc, false)
      return
    end

    npc_id = npc.id

    if Util.in_range?(1500, npc, pc, false)
      log = ExQuestNpcLogList.new(id)

      if MONSTER1.includes?(npc_id) && st.cond?(2)
        if npc_id == MONSTER1[4]
          npc_id = MONSTER1[0]
        elsif npc_id == MONSTER1[5]
          npc_id = MONSTER1[1]
        elsif npc_id == MONSTER1[6]
          npc_id = MONSTER1[2]
        elsif npc_id == MONSTER1[7]
          npc_id = MONSTER1[3]
        end

        i = st.get_int(npc_id.to_s)
        if i < 15
          st.set(npc_id.to_s, (i + 1).to_s)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end

        check_progress(st, 15, MONSTER1[0], MONSTER1[1], MONSTER1[2], MONSTER1[3])

        log.add_npc(MONSTER1[0], st.get_int(MONSTER1[0].to_s))
        log.add_npc(MONSTER1[1], st.get_int(MONSTER1[1].to_s))
        log.add_npc(MONSTER1[2], st.get_int(MONSTER1[2].to_s))
        log.add_npc(MONSTER1[3], st.get_int(MONSTER1[3].to_s))
      elsif MONSTER2.includes?(npc_id) && st.cond?(3)
        if npc_id == MONSTER2[3]
          npc_id = MONSTER2[0]
        elsif npc_id == MONSTER2[4]
          npc_id = MONSTER2[1]
        elsif npc_id == MONSTER2[5]
          npc_id = MONSTER2[2]
        end

        i = st.get_int(npc_id.to_s)
        if i < 20
          st.set(npc_id.to_s, (i + 1).to_s)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end

        check_progress(st, 20, MONSTER2[0], MONSTER2[1], MONSTER2[2])

        log.add_npc(MONSTER2[0], st.get_int(MONSTER2[0].to_s))
        log.add_npc(MONSTER2[1], st.get_int(MONSTER2[1].to_s))
        log.add_npc(MONSTER2[2], st.get_int(MONSTER2[2].to_s))
      elsif MONSTER3.includes?(npc_id) && st.cond?(4)
        if npc_id == MONSTER3[3]
          npc_id = MONSTER3[0]
        elsif npc_id == MONSTER3[4]
          npc_id = MONSTER3[1]
        elsif npc_id == MONSTER3[5]
          npc_id = MONSTER3[2]
        end

        i = st.get_int(npc_id.to_s)
        if i < 20
          st.set(npc_id.to_s, (i + 1).to_s)
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end

        check_progress(st, 20, MONSTER3[0], MONSTER3[1], MONSTER3[2])

        log.add_npc(MONSTER3[0], st.get_int(MONSTER3[0].to_s))
        log.add_npc(MONSTER3[1], st.get_int(MONSTER3[1].to_s))
        log.add_npc(MONSTER3[2], st.get_int(MONSTER3[2].to_s))
      end

      pc.send_packet(log)
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    html = event
    unless st = get_quest_state(pc, false)
      return html
    end

    if event.casecmp?("32734-06.htm")
      st.start_quest
    elsif event.casecmp?("32734-07.html")
      st.set_cond(2, true)
    elsif event.casecmp?("32734-08.html")
      st.set_cond(3, true)
    elsif event.casecmp?("32734-09.html")
      st.set_cond(4, true)
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if party = pc.party?
      party.members.each do |m|
        increase_kill(m, npc)
      end
    else
      increase_kill(pc, npc)
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level >= 84 && pc.quest_completed?("Q10282_ToTheSeedOfAnnihilation")
        html = "32734-01.htm"
      else
        html = "32734-03.html"
      end
    when State::STARTED
        case st.cond
      when 1
        html = "32734-10.html"
      when 2
        html = "32734-11.html"
      when 3
        html = "32734-12.html"
      when 4
        html = "32734-13.html"
      when 5
        st.give_items(REWARD.sample.sample, 1)
        st.exit_quest(QuestType::DAILY, true)
        html = "32734-14.html"
      end
    when State::COMPLETED
      if !st.now_available?
        html = "32734-02.htm"
      else
        st.state = State::CREATED
        if pc.level >= 84 && pc.quest_completed?("Q10282_ToTheSeedOfAnnihilation")
          html = "32734-01.htm"
        else
          html = "32734-03.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end

  private def check_progress(st, count, *mobs)
    mobs.each do |mob|
      if st.get_int(mob.to_s) < count
        return
      end
    end
    st.set_cond(5, true)
  end
end
