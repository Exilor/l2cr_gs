class Scripts::Q00647_InfluxOfMachines < Quest
  # NPC
  private GUTENHAGEN = 32069
  # Monsters
  private MOBS = {
    22801 => 280, # Cruel Pincer Golem
    22802 => 227, # Cruel Pincer Golem
    22803 => 286, # Cruel Pincer Golem
    22804 => 288, # Horrifying Jackhammer Golem
    22805 => 235, # Horrifying Jackhammer Golem
    22806 => 295, # Horrifying Jackhammer Golem
    22807 => 273, # Scout-type Golem No. 28
    22808 => 143, # Scout-type Golem No. 2
    22809 => 629, # Guard Golem
    22810 => 465, # Micro Scout Golem
    22811 => 849, # Great Chaos Golem
    22812 => 463  # Boom Golem
  }
  # Item
  private BROKEN_GOLEM_FRAGMENT = 15521
  private RECIPES = {
    6881, # Recipe: Forgotten Blade (60%)
    6883, # Recipe: Basalt Battlehammer (60%)
    6885, # Recipe: Imperial Staff (60%)
    6887, # Recipe: Angel Slayer (60%)
    6891, # Recipe: Dragon Hunter Axe (60%)
    6893, # Recipe: Saint Spear (60%)
    6895, # Recipe: Demon Splinter (60%)
    6897, # Recipe: Heavens Divider (60%)
    6899, # Recipe: Arcana Mace (60%)
    7580  # Recipe: Draconic Bow (60%)
  }
  # Misc
  private MIN_LEVEL = 70
  private FRAGMENT_COUNT = 500

  def initialize
    super(647, self.class.simple_name, "Influx of Machines")

    add_start_npc(GUTENHAGEN)
    add_talk_id(GUTENHAGEN)
    add_kill_id(MOBS.keys)
    register_quest_items(BROKEN_GOLEM_FRAGMENT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32069-03.htm"
      st.start_quest
      html = event
    when "32069-06.html"
      if st.cond?(2) && st.get_quest_items_count(BROKEN_GOLEM_FRAGMENT) >= FRAGMENT_COUNT
        st.give_items(RECIPES.sample(random: Rnd), 1)
        st.exit_quest(true, true)
        html = event
      else
        html = "32069-07.html"
      end
    else
      # automatically added
    end


    html
  end

  def on_kill(npc, pc, is_summon)
    if member = get_random_party_member(pc, 1)
      st = get_quest_state!(member, false)
      if st.cond?(1) && Rnd.rand(1000) < MOBS[npc.id]
        st.give_items(BROKEN_GOLEM_FRAGMENT, 1)
        if st.get_quest_items_count(BROKEN_GOLEM_FRAGMENT) >= FRAGMENT_COUNT
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "32069-01.htm" : "32069-02.htm"
    when State::STARTED
      if st.cond?(1)
        html = "32069-04.html"
      elsif st.cond?(2) &&
        if st.get_quest_items_count(BROKEN_GOLEM_FRAGMENT) >= FRAGMENT_COUNT
          html = "32069-05.html"
        end
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end