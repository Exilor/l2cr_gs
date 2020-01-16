class Scripts::Q00360_PlunderTheirSupplies < Quest
  # Npc
  private COLEMAN = 30873
  # Misc
  private MIN_LVL = 52
  # Monsters
  private MONSTER_DROP_CHANCES = {
    20666 => 50, # Taik Orc Seeker
    20669 => 75  # Taik Orc Supply Leader
  }
  # Items
  private RECIPE_OF_SUPPLY = 5870
  private SUPPLY_ITEMS = 5872
  private SUSPICIOUS_DOCUMENT_PIECE = 5871

  def initialize
    super(360, self.class.simple_name, "Plunder Their Supplies")

    add_start_npc(COLEMAN)
    add_talk_id(COLEMAN)
    add_kill_id(MONSTER_DROP_CHANCES.keys)
    register_quest_items(
      SUPPLY_ITEMS, SUSPICIOUS_DOCUMENT_PIECE, RECIPE_OF_SUPPLY
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30873-03.htm", "30873-09.html"
      event
    when "30873-04.htm"
      st.start_quest
      event
    when "30873-10.html"
      st.exit_quest(false, true)
      event
    end
  end

  def on_kill(npc, killer, is_pet)
    unless st = get_quest_state(killer, false)
      return super
    end

    unless Util.in_range?(1500, npc, killer, false)
      return super
    end

    if Rnd.rand(100) < MONSTER_DROP_CHANCES[npc.id]
      st.give_items(SUPPLY_ITEMS, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    if Rnd.rand(100) < 10
      if st.get_quest_items_count(SUSPICIOUS_DOCUMENT_PIECE) < 4
        st.give_items(SUSPICIOUS_DOCUMENT_PIECE, 1)
      else
        st.give_items(RECIPE_OF_SUPPLY, 1)
        st.take_items(SUSPICIOUS_DOCUMENT_PIECE, -1)
      end
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "30873-02.htm" : "30873-01.html"
    when State::STARTED
      supply_count = st.get_quest_items_count(SUPPLY_ITEMS)
      recipe_count = st.get_quest_items_count(RECIPE_OF_SUPPLY)
      if supply_count == 0
        if recipe_count == 0
          html = "30873-05.html"
        else
          st.give_adena(recipe_count * 6000, true)
          st.take_items(RECIPE_OF_SUPPLY, -1)
          html = "30873-08.html"
        end
      else
        if recipe_count == 0
          st.give_adena((supply_count * 100) + 6000, true)
          st.take_items(SUPPLY_ITEMS, -1)
          html = "30873-06.html"
        else
          adena = (supply_count * 100) + 6000 + (recipe_count * 6000)
          st.give_adena(adena, true)
          st.take_items(SUPPLY_ITEMS, -1)
          st.take_items(RECIPE_OF_SUPPLY, -1)
          html = "30873-07.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
