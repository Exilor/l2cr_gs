class Scripts::Q00641_AttackSailren < Quest
  # NPC
  private SHILENS_STONE_STATUE = 32109
  # Items
  private GAZKH_FRAGMENT = 8782
  private GAZKH = 8784

  private MOBS = {
    22196, # Velociraptor
    22197, # Velociraptor
    22198, # Velociraptor
    22218, # Velociraptor
    22223, # Velociraptor
    22199, # Pterosaur
  }

  def initialize
    super(641, self.class.simple_name, "Attack Sailren!")

    add_start_npc(SHILENS_STONE_STATUE)
    add_talk_id(SHILENS_STONE_STATUE)
    add_kill_id(MOBS)
    register_quest_items(GAZKH_FRAGMENT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "32109-1.html"
      st.start_quest
    when "32109-2a.html"
      if st.get_quest_items_count(GAZKH_FRAGMENT) >= 30
        st.give_items(GAZKH, 1)
        st.exit_quest(true, true)
      end
    end

    event
  end

  def on_kill(npc, pc, is_summon)
    if member = get_random_party_member(pc, 1)
      if st = get_quest_state(member, false)
        st.give_items(GAZKH_FRAGMENT, 1)
        if st.get_quest_items_count(GAZKH_FRAGMENT) < 30
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        else
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
      if pc.level < 77
        html = "32109-0.htm"
      else
        if pc.quest_completed?(Q00126_TheNameOfEvil2.simple_name)
          html = "32109-0a.htm"
        else
          html = "32109-0b.htm"
        end
      end
    when State::STARTED
      html = st.cond?(1) ? "32109-1a.html" : "32109-2.html"
    end

    html || get_no_quest_msg(pc)
  end
end
