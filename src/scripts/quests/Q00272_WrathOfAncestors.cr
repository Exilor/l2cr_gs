class Scripts::Q00272_WrathOfAncestors < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
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

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.race.orc?
        if pc.level >= MIN_LVL
          html = "30572-03.htm"
        else
          html = "30572-02.htm"
        end
      else
        html = "30572-01.htm"
      end
    when State::STARTED
      case st.cond
      when 1
        html = "30572-05.html"
      when 2
        st.give_adena(1500, true)
        st.exit_quest(true, true)
        html = "30572-06.html"
      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html
  end
end
