class Quests::Q00277_GatekeepersOffering < Quest
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

  def on_adv_event(event, npc, player)
    return unless player
    st = get_quest_state(player, false)
    if st && event.casecmp?("30576-03.htm")
      if player.level < MIN_LEVEL
        return "30576-01.htm"
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

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case st.state
    when State::CREATED
      htmltext = "30576-02.htm"
    when State::STARTED
      if st.cond?(1)
        htmltext = "30576-04.html"
      elsif st.cond?(2) && st.get_quest_items_count(STARSTONE) >= STARSTONE_COUNT
        st.give_items(GATEKEEPER_CHARM, 2)
        st.exit_quest(true, true)
        htmltext = "30576-05.html"
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
