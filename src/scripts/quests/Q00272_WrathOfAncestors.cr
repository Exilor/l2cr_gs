class Quests::Q00272_WrathOfAncestors < Quest
  # NPC
  private LIVINA = 30572
  # Items
  private GRAVE_ROBBERS_HEAD = 1474
  # Monsters
  private MONSTERS = {
    20319, # Goblin Grave Robber
    20320  # Goblin Tomb Raider Leader
  }
  # Misc
  private MIN_LVL = 5

  def initialize
    super(272, self.class.simple_name, "Wrath of Ancestors")

    add_start_npc(LIVINA)
    add_talk_id(LIVINA)
    add_kill_id(MONSTERS)
    register_quest_items(GRAVE_ROBBERS_HEAD)
  end

  def on_adv_event(event, npc, player)
    return unless player
    st = get_quest_state(player, false)
    if st && event.casecmp?("30572-04.htm")
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1)
      st.give_items(GRAVE_ROBBERS_HEAD, 1)
      if st.get_quest_items_count(GRAVE_ROBBERS_HEAD) >= 50
        st.set_cond(2, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::CREATED
      htmltext = player.race.orc? ? player.level >= MIN_LVL ? "30572-03.htm" : "30572-02.htm" : "30572-01.htm"
    when State::STARTED
      case st.cond
      when 1
        htmltext = "30572-05.html"
      when 2
        st.give_adena(1500, true)
        st.exit_quest(true, true)
        htmltext = "30572-06.html"
      end
    end

    htmltext
  end
end
