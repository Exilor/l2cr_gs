class Scripts::Q00169_OffspringOfNightmares < Quest
  # NPC
  private VLASTY = 30145
  # Monsters
  private LESSER_DARK_HORROR = 20025
  private DARK_HORROR = 20105
  # Items
  private BONE_GAITERS = 31
  private CRACKED_SKULL = 1030
  private PERFECT_SKULL = 1031
  # Misc
  private MIN_LVL = 15

  def initialize
    super(169, self.class.simple_name, "Offspring of Nightmares")

    add_start_npc(VLASTY)
    add_talk_id(VLASTY)
    add_kill_id(LESSER_DARK_HORROR, DARK_HORROR)
    register_quest_items(CRACKED_SKULL, PERFECT_SKULL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)

    if st
      case event
      when "30145-03.htm"
        st.start_quest
        html = event
      when "30145-07.html"
        if st.cond?(2) && st.has_quest_items?(PERFECT_SKULL)
          st.give_items(BONE_GAITERS, 1)
          st.add_exp_and_sp(17475, 818)
          st.give_adena(17030i64 + (10 * st.get_quest_items_count(CRACKED_SKULL)), true)
          st.exit_quest(false, true)
          show_on_screen_msg(pc, NpcString::LAST_DUTY_COMPLETE_N_GO_FIND_THE_NEWBIE_GUIDE, 2, 5000) # TODO: Newbie Guide
          html = event
        end
      else
        # automatically added
      end

    end

    html
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.started?
      if Rnd.rand(10) > 7 && !st.has_quest_items?(PERFECT_SKULL)
        st.give_items(PERFECT_SKULL, 1)
        st.set_cond(2, true)
      elsif Rnd.rand(10) > 4
        st.give_items(CRACKED_SKULL, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    if st = get_quest_state!(pc)
      case st.state
      when State::CREATED
        if pc.race.dark_elf?
          if pc.level >= MIN_LVL
            html = "30145-02.htm"
          else
            html = "30145-01.htm"
          end
        else
          html = "30145-00.htm"
        end
      when State::STARTED
        if st.has_quest_items?(CRACKED_SKULL) && !st.has_quest_items?(PERFECT_SKULL)
          html = "30145-05.html"
        elsif st.cond?(2) && st.has_quest_items?(PERFECT_SKULL)
          html = "30145-06.html"
        elsif !st.has_quest_items?(CRACKED_SKULL, PERFECT_SKULL)
          html = "30145-04.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # automatically added
      end

    end

    html || get_no_quest_msg(pc)
  end
end