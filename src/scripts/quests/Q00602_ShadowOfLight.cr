class Scripts::Q00602_ShadowOfLight < Quest
  # NPC
  private EYE_OF_ARGOS = 31683
  # Item
  private EYE_OF_DARKNESS = 7189
  # Monsters
  private MOBS = {
    21299,
    21304
  }

  # Reward
  private REWARD = {
    {
      6699,
      40000,
      120000,
      20000
    },
    {
      6698,
      60000,
      110000,
      15000
    },
    {
      6700,
      40000,
      150000,
      10000
    },
    {
      0,
      100000,
      140000,
      11250
    }
  }

  def initialize
    super(602, self.class.simple_name, "Shadow of Light")

    add_start_npc(EYE_OF_ARGOS)
    add_talk_id(EYE_OF_ARGOS)
    add_kill_id(MOBS)
    register_quest_items(EYE_OF_DARKNESS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "31683-02.htm"
      st.start_quest
    when "31683-05.html"
      if st.get_quest_items_count(EYE_OF_DARKNESS) < 100
        return "31683-06.html"
      end

      i = Rnd.rand(4)
      if i < 3
        st.give_items(REWARD[i][0], 3)
      end
      st.give_adena(REWARD[i][1], true)
      st.add_exp_and_sp(REWARD[i][2], REWARD[i][3])
      st.exit_quest(true, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    unless st = get_quest_state(pc, false)
      return super
    end

    chance = npc.id == MOBS[0] ? 560 : 800

    if st.cond?(1) && Rnd.rand(1000) < chance
      st.give_items(EYE_OF_DARKNESS, 1)
      if st.get_quest_items_count(EYE_OF_DARKNESS) == 100
        st.set_cond(2, true)
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
      html = pc.level >= 68 ? "31683-01.htm" : "31683-00.htm"
    when State::STARTED
      html = st.cond?(1) ? "31683-03.html" : "31683-04.html"
    end


    html || get_no_quest_msg(pc)
  end
end
