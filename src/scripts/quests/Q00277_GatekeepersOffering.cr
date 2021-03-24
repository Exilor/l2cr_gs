class Scripts::Q00277_GatekeepersOffering < Quest
  # NPC
  private TAMIL = 30576
  # Monster
  private GREYSTONE_GOLEM = 20333
  # Items
  private STARSTONE = 1572
  private GATEKEEPER_CHARM = 1658
  # Misc
  private MIN_LEVEL = 15
  private STARSTONE_COUNT = 20

  def initialize
    super(277, self.class.simple_name, "Gatekeeper's Offering")

    add_start_npc(TAMIL)
    add_talk_id(TAMIL)
    add_kill_id(GREYSTONE_GOLEM)
    register_quest_items(STARSTONE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))
    if event.casecmp?("30576-03.htm")
      if pc.level < MIN_LEVEL
        return "30576-01.htm"
      end
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    if st = get_quest_state(killer, false)
      if st.started? && st.get_quest_items_count(STARSTONE) < STARSTONE_COUNT
        st.give_items(STARSTONE, 1)
        if st.get_quest_items_count(STARSTONE) >= STARSTONE_COUNT
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = "30576-02.htm"
    when State::STARTED
      if st.cond?(1)
        html = "30576-04.html"
      elsif st.cond?(2)
        if st.get_quest_items_count(STARSTONE) >= STARSTONE_COUNT
          st.give_items(GATEKEEPER_CHARM, 2)
          st.exit_quest(true, true)
          html = "30576-05.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
