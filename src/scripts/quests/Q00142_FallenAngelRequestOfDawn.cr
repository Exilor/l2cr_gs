class Scripts::Q00142_FallenAngelRequestOfDawn < Quest
  # NPCs
  private RAYMOND = 30289
  private CASIAN = 30612
  private NATOOLS = 30894
  private ROCK = 32368
  # Monsters
  private FALLEN_ANGEL = 27338
  private MOBS = {
    20079 => 338,  # Ant
    20080 => 363,  # Ant Captain
    20081 => 611,  # Ant Overseer
    20082 => 371,  # Ant Recruit
    20084 => 421,  # Ant Patrol
    20086 => 371,  # Ant Guard
    20087 => 900,  # Ant Soldier
    20088 => 1000, # Ant Warrior Captain
    20089 => 431,  # Noble Ant
    20090 => 917   # Noble Ant Leader
  }

  # Items
  private CRYPTOGRAM_OF_THE_ANGEL_SEARCH = 10351
  private PROPHECY_FRAGMENT = 10352
  private FALLEN_ANGEL_BLOOD = 10353
  # Misc
  private MAX_REWARD_LEVEL = 43
  private FRAGMENT_COUNT = 30

  @angel_spawned = false

  def initialize
    super(142, self.class.simple_name, "Fallen Angel - Request of Dawn")

    add_talk_id(NATOOLS, RAYMOND, CASIAN, ROCK)
    add_kill_id(MOBS.keys)
    add_kill_id(FALLEN_ANGEL)
    register_quest_items(
      CRYPTOGRAM_OF_THE_ANGEL_SEARCH, PROPHECY_FRAGMENT, FALLEN_ANGEL_BLOOD
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "30894-02.html", "30289-03.html", "30289-04.html", "30612-03.html",
         "30612-04.html", "30612-06.html", "30612-07.html"
      # do nothing
    when "30894-01.html"
      st.start_quest
    when "30894-03.html"
      st.give_items(CRYPTOGRAM_OF_THE_ANGEL_SEARCH, 1)
      st.set_cond(2, true)
    when "30289-05.html"
      st.unset("talk")
      st.set_cond(3, true)
    when "30612-05.html"
      st.set("talk", "2")
    when "30612-08.html"
      st.unset("talk")
      st.set_cond(4, true)
    when "32368-04.html"
      if @angel_spawned
        return "32368-03.html"
      end
      npc = npc.not_nil!
      add_spawn(FALLEN_ANGEL, npc.x + 100, npc.y + 100, npc.z, 0, false, 120000)
      @angel_spawned = true
      start_quest_timer("despawn", 120000, nil, pc)
    when "despawn"
      if @angel_spawned
        @angel_spawned = false
      end
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    if npc.id == FALLEN_ANGEL
      st = get_quest_state!(pc, false)
      if st.cond?(5)
        st.give_items(FALLEN_ANGEL_BLOOD, 1)
        st.set_cond(6, true)
        @angel_spawned = false
      end
    else
      if member = get_random_party_member(pc, 4)
        st = get_quest_state(member, false).not_nil!
        if Rnd.rand(1000) < MOBS[npc.id]
          st.give_items(PROPHECY_FRAGMENT, 1)
          if st.get_quest_items_count(PROPHECY_FRAGMENT) >= FRAGMENT_COUNT
            st.take_items(PROPHECY_FRAGMENT, -1)
            st.set_cond(5, true)
          else
            st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when NATOOLS
      case st.state
      when State::STARTED
        case st.cond
        when 1
          html = "30894-01.html"
        else
          html = "30894-04.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end

    when RAYMOND
      if st.started?
        case st.cond
        when 1
          html = "30289-01.html"
        when 2
          if st.set?("talk")
            html = "30289-03.html"
          else
            st.take_items(CRYPTOGRAM_OF_THE_ANGEL_SEARCH, -1)
            st.set("talk", "1")
            html = "30289-02.html"
          end
        when 3..5
          html = "30289-06.html"
        when 6
          st.give_adena(92676, true)
          if pc.level <= MAX_REWARD_LEVEL
            st.add_exp_and_sp(223036, 13091)
          end
          st.exit_quest(false, true)
          html = "30289-07.html"
        end

      end
    when CASIAN
      if st.started?
        case st.cond
        when 1, 2
          html = "30612-01.html"
        when 3
          if st.get_int("talk") == 1
            html = "30612-03.html"
          elsif st.get_int("talk") == 2
            html = "30612-06.html"
          else
            html = "30612-02.html"
            st.set("talk", "1")
          end
        when 4..6
          html = "30612-09.html"
        end

      end
    when ROCK
      if st.started?
        case st.cond
        when 5
          html = "32368-02.html"
        when 6
          html = "32368-05.html"
        else
          html = "32368-01.html"
        end
      end
    end


    html || get_no_quest_msg(pc)
  end
end
