class Quests::Q00265_BondsOfSlavery < Quest
  # Item
  private IMP_SHACKLES = 1368
  # NPC
  private KRISTIN = 30357
  # Misc
  private MIN_LVL = 6
  # Monsters
  private MONSTERS = {
    20004 => 5, # Imp
    20005 => 6  # Imp Elder
  }

  def initialize
    super(265, self.class.simple_name, "Bonds of Slavery")

    add_start_npc(KRISTIN)
    add_talk_id(KRISTIN)
    add_kill_id(MONSTERS.keys)
    register_quest_items(IMP_SHACKLES)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless st = get_quest_state(player, false)

    case event
    when "30357-04.htm"
      st.start_quest
      htmltext = event
    when "30357-07.html"
      st.exit_quest(true, true)
      htmltext = event
    when "30357-08.html"
      htmltext = event
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && Rnd.rand(10) < MONSTERS[npc.id]
      st.give_items(IMP_SHACKLES, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    unless st
      return htmltext
    end

    case st.state
    when State::CREATED
      if player.race.dark_elf?
        if player.level >= MIN_LVL
          htmltext = "30357-03.htm"
        else
          htmltext = "30357-02.html"
        end
      else
        htmltext = "30357-01.html"
      end
    when State::STARTED
      if st.has_quest_items?(IMP_SHACKLES)
        shackles = st.get_quest_items_count(IMP_SHACKLES)
        st.give_adena((shackles * 12) + (shackles >= 10 ? 500 : 0), true)
        st.take_items(IMP_SHACKLES, -1)
        Q00281_HeadForTheHills.give_newbie_reward(player)
        htmltext = "30357-06.html"
      else
        htmltext = "30357-05.html"
      end
    end

    htmltext
  end
end
