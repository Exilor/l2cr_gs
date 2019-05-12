class Scripts::Q00905_RefinedDragonBlood < Quest
  # NPCs
  private SEPARATED_SOULS = {
    32864,
    32865,
    32866,
    32867,
    32868,
    32869,
    32870,
    32891
  }
  # Items
  private UNREFINED_RED_DRAGON_BLOOD = 21913
  private UNREFINED_BLUE_DRAGON_BLOOD = 21914
  private REFINED_RED_DRAGON_BLOOD = 21903
  private REFINED_BLUE_DRAGON_BLOOD = 21904
  # Monsters
  private MONSTERS = {
    22844 => UNREFINED_BLUE_DRAGON_BLOOD, # Dragon Knight
    22845 => UNREFINED_BLUE_DRAGON_BLOOD, # Dragon Knight
    22846 => UNREFINED_BLUE_DRAGON_BLOOD, # Elite Dragon Knight
    22847 => UNREFINED_RED_DRAGON_BLOOD,  # Dragon Knight Warrior
    22848 => UNREFINED_RED_DRAGON_BLOOD,  # Drake Leader
    22849 => UNREFINED_RED_DRAGON_BLOOD,  # Drake Warrior
    22850 => UNREFINED_RED_DRAGON_BLOOD,  # Drake Scout
    22851 => UNREFINED_RED_DRAGON_BLOOD,  # Drake Mage
    22852 => UNREFINED_BLUE_DRAGON_BLOOD, # Dragon Guard
    22853 => UNREFINED_BLUE_DRAGON_BLOOD  # Dragon Mage
  }
  # Misc
  private MIN_LEVEL = 83
  private DRAGON_BLOOD_COUNT = 10

  def initialize
    super(905, self.class.simple_name, "Refined Dragon Blood")

    add_start_npc(SEPARATED_SOULS)
    add_talk_id(SEPARATED_SOULS)
    add_kill_id(MONSTERS.keys)
    register_quest_items(
      UNREFINED_RED_DRAGON_BLOOD, UNREFINED_BLUE_DRAGON_BLOOD
    )
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.cond?(1) && Util.in_range?(1500, npc, pc, false)
      item_id = MONSTERS[npc.id]
      if st.get_quest_items_count(item_id) < DRAGON_BLOOD_COUNT
        st.give_items(item_id, 1)

        if st.get_quest_items_count(UNREFINED_RED_DRAGON_BLOOD) >= DRAGON_BLOOD_COUNT && st.get_quest_items_count(UNREFINED_BLUE_DRAGON_BLOOD) >= DRAGON_BLOOD_COUNT
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if pc.level >= MIN_LEVEL
      case event
      when "32864-04.htm", "32864-09.html", "32864-10.html"
        html = event
      when "32864-05.htm"
        st.start_quest
        html = event
      when "32864-11.html"
        st.give_items(REFINED_RED_DRAGON_BLOOD, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        st.exit_quest(QuestType::DAILY, true)
        html = event
      when "32864-12.html"
        st.give_items(REFINED_BLUE_DRAGON_BLOOD, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        st.exit_quest(QuestType::DAILY, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    execute_for_each_player(killer, npc, is_summon, true, false)
    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level < MIN_LEVEL ? "32864-02.html" : "32864-01.htm"
    when State::STARTED
      case st.cond
      when 1
        html = "32864-06.html"
      when 2
        if !st.set?("wait")
          html = "32864-07.html"
          st.set("wait", 1)
        else
          html = "32864-08.html"
        end
      end
    when State::COMPLETED
      if !st.now_available?
        html = "32864-03.html"
      else
        st.state = State::CREATED
        html = pc.level < MIN_LEVEL ? "32864-02.html" : "32864-01.htm"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
