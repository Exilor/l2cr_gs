class Scripts::Q00141_ShadowFoxPart3 < Quest
  # NPCs
  private NATOOLS = 30894
  # Monsters
  private MOBS = {
    20135 => 53,  # Alligator
    20791 => 100, # Crokian Warrior
    20792 => 92   # Farhite
  }
  # Items
  private PREDECESSORS_REPORT = 10350
  # Misc
  private MIN_LEVEL = 37
  private MAX_REWARD_LEVEL = 42
  private REPORT_COUNT = 30

  def initialize
    super(141, self.class.simple_name, "Shadow Fox - 3")

    add_start_npc(NATOOLS)
    add_talk_id(NATOOLS)
    add_kill_id(MOBS.keys)
    register_quest_items(PREDECESSORS_REPORT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "30894-05.html", "30894-10.html", "30894-11.html", "30894-12.html",
         "30894-13.html", "30894-14.html", "30894-16.html", "30894-17.html",
         "30894-19.html", "30894-20.html"
      # do nothing
    when "30894-03.htm"
      st.start_quest
    when "30894-06.html"
      st.set_cond(2, true)
    when "30894-15.html"
      st.set("talk", "2")
    when "30894-18.html"
      st.set_cond(4, true)
      st.unset("talk")
    when "30894-21.html"
      st.give_adena(88888, true)
      if pc.level <= MAX_REWARD_LEVEL
        st.add_exp_and_sp(278005, 17058)
      end
      st.exit_quest(false, true)

      if q = QuestManager.get_quest(Q00998_FallenAngelSelect.simple_name)
        q.new_quest_state(pc).state = State::STARTED
      end
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 2)
      return super
    end

    st = get_quest_state(member, false).not_nil!

    if Rnd.rand(100) < MOBS[npc.id]
      st.give_items(PREDECESSORS_REPORT, 1)
      if st.get_quest_items_count(PREDECESSORS_REPORT) >= REPORT_COUNT
        st.set_cond(3, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level >= MIN_LEVEL
        if pc.quest_completed?(Q00140_ShadowFoxPart2.simple_name)
          html = "30894-01.htm"
        else
          html = "30894-00.html"
        end
      else
        html = "30894-02.htm"
      end
    when State::STARTED
      case st.cond
      when 1
        html = "30894-04.html"
      when 2
        html = "30894-07.html"
      when 3
        if st.get_int("talk") == 1
          html = "30894-09.html"
        elsif st.get_int("talk") == 2
          html = "30894-16.html"
        else
          html = "30894-08.html"
          st.take_items(PREDECESSORS_REPORT, -1)
          st.set("talk", "1")
        end
      when 4
        html = "30894-19.html"
      end

    when State::COMPLETED
      html = get_already_completed_msg(pc)
    end


    html || get_no_quest_msg(pc)
  end
end
