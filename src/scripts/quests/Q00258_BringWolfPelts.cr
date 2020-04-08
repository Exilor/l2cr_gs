class Scripts::Q00258_BringWolfPelts < Quest
  # Npc
  private LECTOR = 30001
  # Item
  private WOLF_PELT = 702
  # Monsters
  private MONSTERS = {
    20120, # Wolf
    20442, # Elder Wolf
  }
  # Rewards
  private REWARDS = {
    390  => 1,  # Cotton Shirt
    29   => 6,  # Leather Pants
    22   => 9,  # Leather Shirt
    1119 => 13, # Short Leather Gloves
    426  => 16  # Tunic
  }
  # Misc
  private MIN_LVL = 3
  private WOLF_PELT_COUNT = 40

  def initialize
    super(258, self.class.simple_name, "Bring Wolf Pelts")

    add_start_npc(LECTOR)
    add_talk_id(LECTOR)
    add_kill_id(MONSTERS)
    register_quest_items(WOLF_PELT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event.casecmp?("30001-03.html")
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1)
      st.give_items WOLF_PELT, 1
      if st.get_quest_items_count(WOLF_PELT) >= WOLF_PELT_COUNT
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
      html = pc.level >= MIN_LVL ? "30001-02.htm" : "30001-01.html"
    when State::STARTED
      case st.cond
      when 1
        html = "30001-04.html"
      when 2
        if st.get_quest_items_count(WOLF_PELT) >= WOLF_PELT_COUNT
          chance = Rnd.rand(16)

          REWARDS.each do |key, val|
            if chance < val
              st.give_items(key, 1)
              break
            end
          end

          st.exit_quest(true, true)
          html = "30001-05.html"
        end
      else
        # automatically added
      end

    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end
