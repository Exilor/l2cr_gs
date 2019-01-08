class Quests::Q00267_WrathOfVerdure < Quest
  # NPC
  private TREANT_BREMEC = 31853
  # Item
  private GOBLIN_CLUB = 1335
  # Monster
  private GOBLIN_RAIDER = 20325
  # Reward
  private SILVERY_LEAF = 1340
  # Misc
  private MIN_LVL = 4

  def initialize
    super(267, self.class.simple_name, "Wrath of Verdure")

    add_start_npc(TREANT_BREMEC)
    add_talk_id(TREANT_BREMEC)
    add_kill_id(GOBLIN_RAIDER)
    register_quest_items(GOBLIN_CLUB)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "31853-04.htm"
      st.start_quest
      htmltext = event
    when "31853-07.html"
      st.exit_quest(true, true)
      htmltext = event
    when "31853-08.html"
      htmltext = event
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && Rnd.rand(10) < 5
      st.give_items(GOBLIN_CLUB, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      htmltext = pc.race.elf? ? pc.level >= MIN_LVL ? "31853-03.htm" : "31853-02.htm" : "31853-01.htm"
    when State::STARTED
      if st.has_quest_items?(GOBLIN_CLUB)
        count = st.get_quest_items_count(GOBLIN_CLUB)
        st.reward_items(SILVERY_LEAF, count)
        if count >= 10
          st.give_adena(600, true)
        end
        st.take_items(GOBLIN_CLUB, -1)
        htmltext = "31853-06.html"
      else
        htmltext = "31853-05.html"
      end
    end

    htmltext || get_no_quest_msg(pc)
  end
end
