class Quests::Q00297_GatekeepersFavor < Quest
  # NPC
  private WIRPHY = 30540
  # Monster
  private WHINSTONE_GOLEM = 20521
  # Items
  private STARSTONE = 1573
  private GATEKEEPER_TOKEN = 1659
  # Misc
  private MIN_LEVEL = 15
  private STARSTONE_COUNT = 20

  def initialize
    super(297, self.class.simple_name, "Gatekeeper's Favor")

    add_start_npc(WIRPHY)
    add_talk_id(WIRPHY)
    add_kill_id(WHINSTONE_GOLEM)
    register_quest_items(STARSTONE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event.casecmp?("30540-03.htm")
      if pc.level < MIN_LEVEL
        return "30540-01.htm"
      end
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.started? && st.get_quest_items_count(STARSTONE) < STARSTONE_COUNT
      st.give_items(STARSTONE, 1)
      if st.get_quest_items_count(STARSTONE) >= STARSTONE_COUNT
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
      htmltext = "30540-02.htm"
    when State::STARTED
      if st.cond?(1)
        htmltext = "30540-04.html"
      elsif st.cond?(2) && st.get_quest_items_count(STARSTONE) >= STARSTONE_COUNT
        st.give_items(GATEKEEPER_TOKEN, 2)
        st.exit_quest(true, true)
        htmltext = "30540-05.html"
      end
    end

    htmltext || get_no_quest_msg(pc)
  end
end
