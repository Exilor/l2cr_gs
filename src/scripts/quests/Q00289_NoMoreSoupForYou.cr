class Scripts::Q00289_NoMoreSoupForYou < Quest
  # NPC
  private STAN = 30200
  # Item
  private SOUP = 15712
  # Misc
  private RATE = 5

  private MOBS = {
    18908,
    22779,
    22786,
    22787,
    22788
  }

  private WEAPONS = {
    {10377, 1},
    {10401, 1},
    {10401, 2},
    {10401, 3},
    {10401, 4},
    {10401, 5},
    {10401, 6}
  }

  private ARMORS = {
    {15812, 1},
    {15813, 1},
    {15814, 1},
    {15791, 1},
    {15787, 1},
    {15784, 1},
    {15781, 1},
    {15778, 1},
    {15775, 1},
    {15774, 5},
    {15773, 5},
    {15772, 5},
    {15693, 5},
    {15657, 5},
    {15654, 5},
    {15651, 5},
    {15648, 5},
    {15645, 5}
  }

  def initialize
    super(289, self.class.simple_name, "No More Soup For You")

    add_start_npc(STAN)
    add_talk_id(STAN)
    add_kill_id(MOBS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    b = Rnd.rand(18)
    c = Rnd.rand(7)
    html = event

    npc = npc.not_nil!

    if npc.id == STAN
      if event.casecmp?("30200-03.htm")
        st.start_quest
      elsif event.casecmp?("30200-05.htm")
        if st.get_quest_items_count(SOUP) >= 500
          st.give_items(WEAPONS[c][0], WEAPONS[c][1])
          st.take_items(SOUP, 500)
          st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          html = "30200-04.htm"
        else
          html = "30200-07.htm"
        end
      elsif event.casecmp?("30200-06.htm")
        if st.get_quest_items_count(SOUP) >= 100
          st.give_items(ARMORS[b][0], ARMORS[b][1])
          st.take_items(SOUP, 100)
          st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          html = "30200-04.htm"
        else
          html = "30200-07.htm"
        end
      end
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)
    unless st && st.state.started?
      return
    end

    if MOBS.includes?(npc.id)
      st.give_items(SOUP, RATE)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if npc.id == STAN
      case st.state
      when State::CREATED
        if pc.quest_completed?(Q00252_ItSmellsDelicious.simple_name) && pc.level >= 82
          html = "30200-01.htm"
        else
          html = "30200-00.htm"
        end
      when State::STARTED
        if st.cond?(1)
          if st.get_quest_items_count(SOUP) >= 100
            html = "30200-04.htm"
          else
            html = "30200-03.htm"
          end
        end
      else
        # [automatically added else]
      end

    end

    html || get_no_quest_msg(pc)
  end
end
