class Quests::Q00288_HandleWithCare < Quest
  # NPC
  private ANKUMI = 32741
  # Monster
  private SEER_UGOROS = 18863
  # Items
  private HIGH_GRADE_LIZARD_SCALE = 15497
  private MIDDLE_GRADE_LIZARD_SCALE = 15498
  private SCROLL_ENCHANT_WEAPON_S_GRADE = 959
  private SCROLL_ENCHANT_ARMOR_S_GRADE = 960
  private HOLY_CRYSTAL = 9557
  private REWARDS = {
    ItemHolder.new(SCROLL_ENCHANT_WEAPON_S_GRADE, 1),
    ItemHolder.new(SCROLL_ENCHANT_ARMOR_S_GRADE, 1),
    ItemHolder.new(SCROLL_ENCHANT_ARMOR_S_GRADE, 2),
    ItemHolder.new(SCROLL_ENCHANT_ARMOR_S_GRADE, 3),
    ItemHolder.new(HOLY_CRYSTAL, 1),
    ItemHolder.new(HOLY_CRYSTAL, 2)
  }
  # Misc
  private MIN_LEVEL = 82

  def initialize
    super(288, self.class.simple_name, "Handle With Care")

    add_start_npc(ANKUMI)
    add_talk_id(ANKUMI)
    add_kill_id(SEER_UGOROS)
    register_quest_items(HIGH_GRADE_LIZARD_SCALE, MIDDLE_GRADE_LIZARD_SCALE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = nil
    case event
    when "32741-03.htm"
      if pc.level >= MIN_LEVEL
        html = event
      end
    when "32741-04.html"
      if pc.level >= MIN_LEVEL
        st.start_quest
        html = event
      end
    when "32741-08.html"
      if st.cond?(2) || st.cond?(3)
        if st.has_quest_items?(MIDDLE_GRADE_LIZARD_SCALE)
          st.take_items(MIDDLE_GRADE_LIZARD_SCALE, 1)
          rnd = rand(10)
          if rnd == 0
            reward = REWARDS[0]
          elsif rnd < 4
            reward = REWARDS[1]
          elsif rnd < 6
            reward = REWARDS[2]
          elsif rnd < 7
            reward = REWARDS[3]
          elsif rnd < 9
            reward = REWARDS[4]
          else
            reward = REWARDS[5]
          end
        elsif st.has_quest_items?(HIGH_GRADE_LIZARD_SCALE)
          st.take_items(HIGH_GRADE_LIZARD_SCALE, 1)
          rnd = rand(10)
          if rnd == 0
            reward = REWARDS[0]
          elsif rnd < 5
            reward = REWARDS[1]
          elsif rnd < 8
            reward = REWARDS[2]
          else
            reward = REWARDS[3]
          end
          st.give_items(REWARDS[4])
        end
        if reward
          st.give_items(reward)
        end
        st.exit_quest(true, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1) && Util.in_range?(1500, npc, killer, false)
      if !st.has_quest_items?(MIDDLE_GRADE_LIZARD_SCALE)
        st.give_items(MIDDLE_GRADE_LIZARD_SCALE, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        st.set_cond(2, true)
      elsif !st.has_quest_items?(HIGH_GRADE_LIZARD_SCALE)
        st.give_items(HIGH_GRADE_LIZARD_SCALE, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        st.set_cond(3, true)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level < MIN_LEVEL ? "32741-01.html" : "32741-02.htm"
    when State::STARTED
      if st.cond?(1) && !st.has_quest_items?(HIGH_GRADE_LIZARD_SCALE) && !st.has_quest_items?(MIDDLE_GRADE_LIZARD_SCALE)
        html = "32741-05.html"
      elsif st.cond?(2) && st.has_quest_items?(MIDDLE_GRADE_LIZARD_SCALE)
        html = "32741-06.html"
      end

      if st.cond?(2) && st.has_quest_items?(HIGH_GRADE_LIZARD_SCALE)
        html = "32741-07.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
