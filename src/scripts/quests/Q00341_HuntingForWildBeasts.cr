class Scripts::Q00341_HuntingForWildBeasts < Quest
  # NPCs
  private PANO = 30078
  # Monsters
  private MONSTERS = {
    20203 => 99,
    20310 => 87,
    20021 => 83,
    20335 => 87
  }
  # Items
  private BEAR_SKIN = 4259
  # Misc
  private MIN_LVL = 20
  private ADENA_COUNT = 3710
  private REQUIRED_COUNT = 20

  def initialize
    super(341, self.class.simple_name, "Hunting for Wild Beasts")

    add_start_npc(PANO)
    add_talk_id(PANO)
    add_kill_id(MONSTERS.keys)
    register_quest_items(BEAR_SKIN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    if st = get_quest_state(pc, false)
      case event
      when "30078-03.htm"
        html = event
      when "30078-04.htm"
        st.start_quest
        html = event
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc, true)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "30078-01.html" : "30078-02.htm"
    when State::STARTED
      if st.cond?(2) && st.get_quest_items_count(BEAR_SKIN) >= REQUIRED_COUNT
        st.give_adena(ADENA_COUNT, true)
        st.exit_quest(true, true)
        html = "30078-05.html"
      else
        html = "30078-06.html"
      end
    end

    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, pc, is_pet)
    st = get_quest_state(pc, false)
    if st && st.cond?(1)
      skins = st.get_quest_items_count(BEAR_SKIN)
      if skins < REQUIRED_COUNT
        if Rnd.rand(100) < MONSTERS[npc.id]
          st.give_items(BEAR_SKIN, 1)
          if skins + 1 < REQUIRED_COUNT
            st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
          else
            st.set_cond(2, true)
          end
        end
      end
    end

    super
  end
end
