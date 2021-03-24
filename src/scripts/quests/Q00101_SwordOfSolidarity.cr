class Scripts::Q00101_SwordOfSolidarity < Quest
  # NPCs
  private ROIEN = 30008
  private ALTRAN = 30283
  # Items
  private BROKEN_SWORD_HANDLE = 739
  private BROKEN_BLADE_BOTTOM = 740
  private BROKEN_BLADE_TOP = 741
  private ALTRANS_NOTE = 742
  private ROIENS_LETTER = 796
  private DIRECTIONS_TO_RUINS = 937
  # Monsters
  private MONSTERS = {
    20361, # Tunath Orc Marksman
    20362  # Tunath Orc Warrior
  }
  # Rewards
  private REWARDS = {
    ItemHolder.new(738, 1), # Sword of Solidarity
    ItemHolder.new(1060, 100), # Lesser Healing Potion
    ItemHolder.new(4412, 10), # Echo Crystal - Theme of Battle
    ItemHolder.new(4413, 10), # Echo Crystal - Theme of Love
    ItemHolder.new(4414, 10), # Echo Crystal - Theme of Solitude
    ItemHolder.new(4415, 10), # Echo Crystal - Theme of Feast
    ItemHolder.new(4416, 10), # Echo Crystal - Theme of Celebration
  }
  # Misc
  private MIN_LVL = 9

  def initialize
    super(101, self.class.simple_name, "Sword of Solidarity")

    add_start_npc(ROIEN)
    add_kill_id(MONSTERS)
    add_talk_id(ROIEN, ALTRAN)
    register_quest_items(
      BROKEN_SWORD_HANDLE, BROKEN_BLADE_BOTTOM, BROKEN_BLADE_TOP, ALTRANS_NOTE,
      ROIENS_LETTER, DIRECTIONS_TO_RUINS
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless st = get_quest_state(pc, false)

    case event
    when "30008-03.html", "30008-09.html"
      html = event
    when "30008-04.htm"
      st.start_quest
      st.give_items(ROIENS_LETTER, 1)
      html = event
    when "30283-02.html"
      if st.cond?(1) && st.has_quest_items?(ROIENS_LETTER)
        st.take_items(ROIENS_LETTER, -1)
        st.give_items(DIRECTIONS_TO_RUINS, 1)
        st.set_cond(2, true)
        html = event
      end
    when "30283-07.html"
      if st.cond?(5) && st.has_quest_items?(BROKEN_SWORD_HANDLE)
        Q00281_HeadForTheHills.give_newbie_reward(pc)
        REWARDS.each { |rw| st.give_items(rw) }
        st.add_exp_and_sp(25_747, 2171)
        st.give_adena(10_981, true)
        st.exit_quest(false, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)

    if st && st.cond?(2) && Rnd.rand(5) == 0
      if !st.has_quest_items?(BROKEN_BLADE_TOP)
        st.give_items(BROKEN_BLADE_TOP, 1)
        if st.has_quest_items?(BROKEN_BLADE_BOTTOM)
          st.set_cond(3, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      elsif !st.has_quest_items?(BROKEN_BLADE_BOTTOM)
        st.give_items(BROKEN_BLADE_BOTTOM, 1)
        if st.has_quest_items?(BROKEN_BLADE_TOP)
          st.set_cond(3, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when ROIEN
      case st.state
      when State::CREATED
        if pc.race.human?
          if pc.level >= MIN_LVL
            html = "30008-02.htm"
          else
            html = "30008-08.htm"
          end
        else
          html = "30008-01.htm"
        end
      when State::STARTED
        case st.cond
        when 1
          if st.has_quest_items?(ROIENS_LETTER)
            html = "30008-05.html"
          end
        when 2
          if has_at_least_one_quest_item?(pc, BROKEN_BLADE_BOTTOM, BROKEN_BLADE_TOP)
            html = "30008-11.html"
          elsif st.has_quest_items?(DIRECTIONS_TO_RUINS)
            html = "30008-10.html"
          end
        when 3
          if st.has_quest_items?(BROKEN_BLADE_BOTTOM, BROKEN_BLADE_TOP)
            html = "30008-12.html"
          end
        when 4
          if st.has_quest_items?(ALTRANS_NOTE)
            st.take_items(ALTRANS_NOTE, -1)
            st.give_items(BROKEN_SWORD_HANDLE, 1)
            st.set_cond(5, true)
            html = "30008-06.html"
          end
        when 5
          if st.has_quest_items?(BROKEN_SWORD_HANDLE)
            html = "30008-07.html"
          end
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when ALTRAN
      case st.cond
      when 1
        if st.has_quest_items?(ROIENS_LETTER)
          html = "30283-01.html"
        end
      when 2
        if has_at_least_one_quest_item?(pc, BROKEN_BLADE_BOTTOM, BROKEN_BLADE_TOP)
          html = "30283-08.html"
        elsif st.has_quest_items?(DIRECTIONS_TO_RUINS)
          html = "30283-03.html"
        end
      when 3
        if st.has_quest_items?(BROKEN_BLADE_BOTTOM, BROKEN_BLADE_TOP)
          take_items(pc, -1, {DIRECTIONS_TO_RUINS, BROKEN_BLADE_TOP, BROKEN_BLADE_BOTTOM})
          st.give_items(ALTRANS_NOTE, 1)
          st.set_cond(4, true)
          html = "30283-04.html"
        end
      when 4
        if st.has_quest_items?(ALTRANS_NOTE)
          html = "30283-05.html"
        end
      when 5
        if st.has_quest_items?(BROKEN_SWORD_HANDLE)
          html = "30283-06.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
