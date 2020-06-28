class Scripts::Q00259_RequestFromTheFarmOwner < Quest
  # Npcs
  private EDMOND = 30497
  private MARIUS = 30405
  # Monsters
  private MONSTERS = {
    20103, # Giant Spider
    20106, # Talon Spider
    20108  # Blade Spider
  }
  # Items
  private SPIDER_SKIN = 1495
  # Misc
  private MIN_LVL = 15
  private SKIN_COUNT = 10
  private SKIN_REWARD = 25
  private SKIN_BONUS = 250
  private CONSUMABLES = {
    "30405-04.html"  => ItemHolder.new(1061, 2),  # Greater Healing Potion
    "30405-05.html"  => ItemHolder.new(17, 250),  # Wooden Arrow
    "30405-05a.html" => ItemHolder.new(1835, 60), # Soulshot: No Grade
    "30405-05c.html" => ItemHolder.new(2509, 30)  # Spiritshot: No Grade
  }

  def initialize
    super(259, self.class.simple_name, "Request from the Farm Owner")

    add_start_npc(EDMOND)
    add_talk_id(EDMOND, MARIUS)
    add_kill_id(MONSTERS)
    register_quest_items(SPIDER_SKIN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30405-03.html", "30405-05b.html", "30405-05d.html", "30497-07.html"
      html = event
    when "30405-04.html", "30405-05.html", "30405-05a.html", "30405-05c.html"
      if st.get_quest_items_count(SPIDER_SKIN) >= SKIN_COUNT
        st.give_items(CONSUMABLES[event])
        st.take_items(SPIDER_SKIN, SKIN_COUNT)
        html = event
      end
    when "30405-06.html"
      html = st.get_quest_items_count(SPIDER_SKIN) >= SKIN_COUNT ? event : "30405-07.html"
    when "30497-03.html"
      st.start_quest
      html = event
    when "30497-06.html"
      st.exit_quest(true, true)
      html = event
    end


    html
  end

  def on_kill(npc, killer, is_summon)
    if st = get_quest_state(killer, false)
      st.give_items(SPIDER_SKIN, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when EDMOND
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LVL ? "30497-02.htm" : "30497-01.html"
      when State::STARTED
        if st.has_quest_items?(SPIDER_SKIN)
          skins = st.get_quest_items_count(SPIDER_SKIN)
          st.give_adena((skins * SKIN_REWARD) + (skins >= 10 ? SKIN_BONUS : 0), true)
          st.take_items(SPIDER_SKIN, -1)
          html = "30497-05.html"
        else
          html = "30497-04.html"
        end
      end

    when MARIUS
      if st.get_quest_items_count(SPIDER_SKIN) >= SKIN_COUNT
        html = "30405-02.html"
      else
        html = "30405-01.html"
      end
    end


    html || get_no_quest_msg(pc)
  end
end
