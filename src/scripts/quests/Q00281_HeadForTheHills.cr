class Scripts::Q00281_HeadForTheHills < Quest
  # Item
  private CLAWS = 9796
  # NPC
  private MERCELA = 32173
  # Message
  private MESSAGE = ExShowScreenMessage.new(NpcString::ACQUISITION_OF_SOULSHOT_FOR_BEGINNERS_COMPLETE_N_GO_FIND_THE_NEWBIE_GUIDE, 2, 5000)
  # Misc
  private MIN_LVL = 6
  # Monsters
  private MONSTERS = {
    22234 => 390, # Green Goblin
    22235 => 450, # Mountain Werewolf
    22236 => 650, # Muertos Archer
    22237 => 720, # Mountain Fungus
    22238 => 920, # Mountain Werewolf Chief
    22239 => 990  # Muertos Guard
  }
  # Rewards
  private REWARDS = {
    115,  # Earring of Wisdom
    876,  # Ring of Anguish
    907,  # Necklace of Anguish
    22,   # Leather Shirt
    428,  # Feriotic Tunic
    1100, # Cotton Tunic
    29,   # Leather Pants
    463,  # Feriotic Stockings
    1103, # Cotton Stockings
    736   # Scroll of Escape
  }

  private SOULSHOTS_NO_GRADE_FOR_ROOKIES = ItemHolder.new(5789, 6000)
  private SPIRITSHOTS_NO_GRADE_FOR_ROOKIES = ItemHolder.new(5790, 3000)

  def initialize
    super(281, self.class.simple_name, "Head for the Hills!")

    add_start_npc(MERCELA)
    add_talk_id(MERCELA)
    add_kill_id(MONSTERS.keys)
    register_quest_items(CLAWS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "32173-03.htm"
      st.start_quest
      event
    when "32173-06.html"
      if st.has_quest_items?(CLAWS)
        claws = st.get_quest_items_count(CLAWS)
        st.give_adena(((claws * 23) + (claws >= 10 ? 400 : 0)), true)
        st.take_items(CLAWS, -1)
        self.class.give_newbie_reward(pc)
        event
      else
        "32173-07.html"
      end
    when "32173-08.html"
      event
    when "32173-09.html"
      st.exit_quest(true, true)
      event
    when "32173-11.html"
      if st.get_quest_items_count(CLAWS) >= 50
        if Rnd.rand(1000) <= 360
          st.give_items(REWARDS[rand(9)], 1)
        else
          st.give_items(REWARDS[9], 1)
        end

        st.take_items(CLAWS, 50)
        self.class.give_newbie_reward(pc)
        event
      else
        "32173-10.html"
      end
    end

  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && Rnd.rand(1000) <= MONSTERS[npc.id]
      st.give_items(CLAWS, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case st.state
    when State::CREATED
      pc.level >= MIN_LVL ? "32173-01.htm" : "32173-02.htm"
    when State::STARTED
      st.has_quest_items?(CLAWS) ? "32173-05.html" : "32173-04.html"
    else
      get_no_quest_msg(pc)
    end
  end

  def self.give_newbie_reward(pc)
    vars = pc.variables
    if pc.level < 25 && !vars.get_bool("NEWBIE_SHOTS", false)
      if pc.mage_class?
        give_items(pc, SPIRITSHOTS_NO_GRADE_FOR_ROOKIES)
        play_sound(pc, Voice::TUTORIAL_VOICE_027_1000)
      else
        give_items(pc, SOULSHOTS_NO_GRADE_FOR_ROOKIES)
        play_sound(pc, Voice::TUTORIAL_VOICE_026_1000)
      end

      vars["NEWBIE_SHOTS"] = true
    end

    if !vars.has_key?("GUIDE_MISSION")
      vars["GUIDE_MISSION"] = 1000
      pc.send_packet(MESSAGE)
    elsif (vars.get_i32("GUIDE_MISSION") % 10000) / 1000 != 1
      vars["GUIDE_MISSION"] = vars.get_i32("GUIDE_MISSION") + 1000
      pc.send_packet(MESSAGE)
    end
  end
end
