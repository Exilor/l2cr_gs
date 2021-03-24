class Scripts::Q00163_LegacyOfThePoet < Quest
  # NPC
  private STARDEN = 30220
  # Monsters
  private MONSTERS = {
    20372, # Baraq Orc Fighter
    20373  # Baraq Orc Warrior Leader
  }
  # Items
  private RUMIELS_1ST_POEM = 1038
  private RUMIELS_2ND_POEM = 1039
  private RUMIELS_3RD_POEM = 1040
  private RUMIELS_4TH_POEM = 1041
  # Misc
  private MIN_LVL = 11

  def initialize
    super(163, self.class.simple_name, "Legacy of the Poet")

    add_start_npc(STARDEN)
    add_talk_id(STARDEN)
    add_kill_id(MONSTERS)
    register_quest_items(
      RUMIELS_1ST_POEM, RUMIELS_2ND_POEM, RUMIELS_3RD_POEM, RUMIELS_4TH_POEM
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc

    if st = get_quest_state(pc, false)
      case event
      when "30220-03.html", "30220-04.html"
        html = event
      when "30220-05.htm"
        st.start_quest
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1)
      if Rnd.rand(10) == 0 && !st.has_quest_items?(RUMIELS_1ST_POEM)
        st.give_items(RUMIELS_1ST_POEM, 1)
        if st.has_quest_items?(RUMIELS_2ND_POEM, RUMIELS_3RD_POEM, RUMIELS_4TH_POEM)
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
      if Rnd.rand(10) > 7 && !st.has_quest_items?(RUMIELS_2ND_POEM)
        st.give_items(RUMIELS_2ND_POEM, 1)
        if st.has_quest_items?(RUMIELS_1ST_POEM, RUMIELS_3RD_POEM, RUMIELS_4TH_POEM)
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
      if Rnd.rand(10) > 7 && !st.has_quest_items?(RUMIELS_3RD_POEM)
        st.give_items(RUMIELS_3RD_POEM, 1)
        if st.has_quest_items?(RUMIELS_1ST_POEM, RUMIELS_2ND_POEM, RUMIELS_4TH_POEM)
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
      if Rnd.rand(10) > 5 && !st.has_quest_items?(RUMIELS_4TH_POEM)
        st.give_items(RUMIELS_4TH_POEM, 1)
        if st.has_quest_items?(RUMIELS_1ST_POEM, RUMIELS_2ND_POEM, RUMIELS_3RD_POEM)
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    if st = get_quest_state(pc, true)
      case st.state
      when State::CREATED
        if !pc.race.dark_elf?
          if pc.level >= MIN_LVL
            html = "30220-02.htm"
          else
            html = "30220-01.htm"
          end
        else
          html = "30220-00.htm"
        end
      when State::STARTED
        if st.has_quest_items?(RUMIELS_1ST_POEM, RUMIELS_2ND_POEM, RUMIELS_3RD_POEM, RUMIELS_4TH_POEM)
          st.add_exp_and_sp(21_643, 943)
          st.give_adena(13_890, true)
          st.exit_quest(false, true)
          html = "30220-07.html"
        else
          html = "30220-06.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
