class Quests::Q00324_SweetestVenom < Quest
  # NPCs
  private ASTARON = 30351
  # Monsters
  private MONSTERS = {
    20034 => 26,
    20038 => 29,
    20043 => 30
  }
  # Items
  private VENOM_SAC = 1077
  # Misc
  private MIN_LVL = 18
  private REQUIRED_COUNT = 10
  private ADENA_COUNT = 5810

  def initialize
    super(324, self.class.simple_name, "Sweetest Venom")

    add_start_npc(ASTARON)
    add_talk_id(ASTARON)
    add_kill_id(MONSTERS.keys)
    register_quest_items(VENOM_SAC)
  end

  def on_adv_event(event, npc, player)
    return unless player
    st = get_quest_state(player, false)

    if st
      st.start_quest
      if event == "30351-04.htm"
        htmltext = event
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)

    if st
      case st.state
      when State::CREATED
        htmltext = player.level < MIN_LVL ? "30351-02.html" : "30351-03.htm"
      when State::STARTED
        if st.cond?(2)
          st.give_adena(ADENA_COUNT, true)
          st.exit_quest(true, true)
          htmltext = "30351-06.html"
        else
          htmltext = "30351-05.html"
        end
      end
    end

    htmltext
  end

  def on_kill(npc, player, is_pet)
    st = get_quest_state(player, false)
    if st && st.cond?(1)
      sacs = st.get_quest_items_count(VENOM_SAC)
      if sacs < REQUIRED_COUNT
        if Rnd.rand(100) < MONSTERS[npc.id]
          st.give_items(VENOM_SAC, 1)
          if sacs + 1 < REQUIRED_COUNT
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
