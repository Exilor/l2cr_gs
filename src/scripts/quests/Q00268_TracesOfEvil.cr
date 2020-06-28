class Scripts::Q00268_TracesOfEvil < Quest
  # NPC
  private KUNAI = 30559
  # Item
  private CONTAMINATED_KASHA_SPIDER_VENOM = 10869
  # Monsters
  private MONSTERS = {
    20474, # Kasha Spider
    20476, # Kasha Fang Spider
    20478  # Kasha Blade Spider
  }
  # Misc
  private MIN_LVL = 15

  def initialize
    super(268, self.class.simple_name, "Traces of Evil")

    add_start_npc(KUNAI)
    add_talk_id(KUNAI)
    add_kill_id(MONSTERS)
    register_quest_items(CONTAMINATED_KASHA_SPIDER_VENOM)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event.casecmp?("30559-03.htm")
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1)
      st.give_items(CONTAMINATED_KASHA_SPIDER_VENOM, 1)
      if st.get_quest_items_count(CONTAMINATED_KASHA_SPIDER_VENOM) >= 30
        st.set_cond(2, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    if st = get_quest_state(pc, true)
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LVL ? "30559-02.htm" : "30559-01.htm"
      when State::STARTED
        case st.cond
        when 1
          if st.has_quest_items?(CONTAMINATED_KASHA_SPIDER_VENOM)
            html = "30559-04.html"
          else
            html = "30559-05.html"
          end
        when 2
          if st.get_quest_items_count(CONTAMINATED_KASHA_SPIDER_VENOM) >= 30
            st.give_adena(2474, true)
            st.add_exp_and_sp(8738, 409)
            st.exit_quest(true, true)
            html = "30559-06.html"
          end
        end

      end

    end

    html || get_no_quest_msg(pc)
  end
end
