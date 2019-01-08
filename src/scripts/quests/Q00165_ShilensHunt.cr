class Quests::Q00165_ShilensHunt < Quest
  # NPC
  private NELSYA = 30348
  # Monsters
  private MONSTERS = {
    20456 => 3, # Ashen Wolf
    20529 => 1, # Young Brown Keltir
    20532 => 1, # Brown Keltir
    20536 => 2  # Elder Brown Keltir
  }
  # Items
  private LESSER_HEALING_POTION = 1060
  private DARK_BEZOAR = 1160
  # Misc
  private MIN_LVL = 3
  private REQUIRED_COUNT = 13

  def initialize
    super(165, self.class.simple_name, "Shilen's Hunt")

    add_start_npc(NELSYA)
    add_talk_id(NELSYA)
    add_kill_id(MONSTERS.keys)
    register_quest_items(DARK_BEZOAR)
  end

  def on_adv_event(event, npc, player)
    return unless player
    st = get_quest_state(player, false)
    if st && event.casecmp?("30348-03.htm")
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1) && Rnd.rand(3) < MONSTERS[npc.id]
      st.give_items(DARK_BEZOAR, 1)
      if st.get_quest_items_count(DARK_BEZOAR) < REQUIRED_COUNT
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      else
        st.set_cond(2, true)
      end
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state(player, true)
    htmltext = get_no_quest_msg(player)
    if st
      case st.state
      when State::CREATED
        htmltext = player.race.dark_elf? ? player.level >= MIN_LVL ? "30348-02.htm" : "30348-01.htm" : "30348-00.htm"
      when State::STARTED
        if st.cond?(2) && st.get_quest_items_count(DARK_BEZOAR) >= REQUIRED_COUNT
          st.give_items(LESSER_HEALING_POTION, 5)
          st.add_exp_and_sp(1000, 0)
          st.exit_quest(false, true)
          htmltext = "30348-05.html"
        else
          htmltext = "30348-04.html"
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    end

    htmltext
  end
end
