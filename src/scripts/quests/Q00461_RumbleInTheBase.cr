class Scripts::Q00461_RumbleInTheBase < Quest
  # NPC
  private STAN = 30200
  # Items
  private SHINY_SALMON = 15503
  private SHOES_STRING_OF_SEL_MAHUM = 16382
  # Mobs
  private MONSTERS = {
    22780 => 581,
    22781 => 772,
    22782 => 581,
    22783 => 563,
    22784 => 581,
    22785 => 271,
    18908 => 782
  }

  def initialize
    super(461, self.class.simple_name, "Rumble in the Base")

    add_start_npc(STAN)
    add_talk_id(STAN)
    add_kill_id(MONSTERS.keys)
    register_quest_items(SHINY_SALMON, SHOES_STRING_OF_SEL_MAHUM)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if event.casecmp?("30200-05.htm")
      st.start_quest
      event
    elsif event.casecmp?("30200-04.htm")
      event
    end
  end

  def on_kill(npc, pc, is_summon)
    if Rnd.rand(1000) >= MONSTERS[npc.id]
      return super
    end

    if npc.id == 18908
      st = get_quest_state(pc, false)
      if st && st.cond?(1) && st.get_quest_items_count(SHINY_SALMON) < 5
        st.give_items(SHINY_SALMON, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        if st.get_quest_items_count(SHINY_SALMON) >= 5 && st.get_quest_items_count(SHOES_STRING_OF_SEL_MAHUM) >= 10
          st.set_cond(2, true)
        end
      end
    else
      unless m = get_random_party_member(pc, 1)
        return super
      end

      st = get_quest_state!(m, false)
      if st.get_quest_items_count(SHOES_STRING_OF_SEL_MAHUM) < 10
        st.give_items(SHOES_STRING_OF_SEL_MAHUM, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        if st.get_quest_items_count(SHINY_SALMON) >= 5 && st.get_quest_items_count(SHOES_STRING_OF_SEL_MAHUM) >= 10
          st.set_cond(2, true)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::CREATED
      if pc.level >= 82 && pc.quest_completed?(Q00252_ItSmellsDelicious.simple_name)
        html = "30200-01.htm"
      else
        html = "30200-02.htm"
      end
    when State::STARTED
      if st.cond?(1)
        html = "30200-06.html"
      else
        st.add_exp_and_sp(224784, 342528)
        st.exit_quest(QuestType::DAILY, true)
        html = "30200-07.html"
      end
    when State::COMPLETED
      if !st.now_available?
        html = "30200-03.htm"
      else
        st.state = State::CREATED
        if pc.level >= 82 && pc.quest_completed?(Q00252_ItSmellsDelicious.simple_name)
          html = "30200-01.htm"
        else
          html = "30200-02.htm"
        end
      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
