class Scripts::Q00601_WatchingEyes < Quest
  # NPC
  private EYE_OF_ARGOS = 31683
  # Item
  private PROOF_OF_AVENGER = 7188
  # Monsters
  private MOBS = {
    21308 => 790,
    21309 => 820,
    21306 => 850,
    21310 => 680,
    21311 => 630
  }

  # Reward
  private REWARD = {
    {
      6699,
      90000
    },
    {
      6698,
      80000
    },
    {
      6700,
      40000
    },
    {
      0,
      230000
    }
  }

  def initialize
    super(601, self.class.simple_name, "Watching Eyes")

    add_start_npc(EYE_OF_ARGOS)
    add_talk_id(EYE_OF_ARGOS)
    add_kill_id(MOBS.keys)
    register_quest_items(PROOF_OF_AVENGER)
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
      if st.get_quest_items_count(PROOF_OF_AVENGER) < 100
        return "31683-06.html"
      end

      i = Rnd.rand(4)
      if i < 3
        st.give_items(REWARD[i][0], 5)
        st.add_exp_and_sp(120000, 10000)
      end
      st.give_adena(REWARD[i][1], true)
      st.exit_quest(true, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)

    if st && st.cond?(1) && Rnd.rand(1000) < MOBS[npc.id]
      st.give_items(PROOF_OF_AVENGER, 1)
      if st.get_quest_items_count(PROOF_OF_AVENGER) == 100
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
      html = pc.level >= 71 ? "31683-01.htm" : "31683-00.htm"
    when State::STARTED
      html = st.cond?(1) ? "31683-03.html" : "31683-04.html"
    end

    html || get_no_quest_msg(pc)
  end
end
