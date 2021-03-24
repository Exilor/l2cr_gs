class Scripts::Q00432_BirthdayPartySong < Quest
  # NPC
  private OCTAVIA = 31043
  # Monster
  private GOLEM = 21103
  # Item
  private RED_CRYSTAL = 7541
  # Reward
  private ECHO_CRYSTAL = 7061

  def initialize
    super(432, self.class.simple_name, "Birthday Party Song")

    add_start_npc(OCTAVIA)
    add_talk_id(OCTAVIA)
    add_kill_id(GOLEM)
    register_quest_items(RED_CRYSTAL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    html = event
    case event
    when "31043-02.htm"
      st.start_quest
    when "31043-05.html"
      if st.get_quest_items_count(RED_CRYSTAL) < 50
        return "31043-06.html"
      end

      st.give_items(ECHO_CRYSTAL, 25)
      st.exit_quest(true, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)

    if st && st.cond?(1) && Rnd.bool
      st.give_items(RED_CRYSTAL, 1)
      if st.get_quest_items_count(RED_CRYSTAL) == 50
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
      html = pc.level >= 31 ? "31043-01.htm" : "31043-00.htm"
    when State::STARTED
      html = st.cond?(1) ? "31043-03.html" : "31043-04.html"
    end

    html || get_no_quest_msg(pc)
  end
end
