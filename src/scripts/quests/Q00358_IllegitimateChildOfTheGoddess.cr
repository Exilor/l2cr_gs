class Scripts::Q00358_IllegitimateChildOfTheGoddess < Quest
  # NPC
  private OLTRAN = 30862
  # Item
  private SNAKE_SCALE = 5868
  # Misc
  private MIN_LEVEL = 63
  private SNAKE_SCALE_COUNT = 108
  # Rewards
  private REWARDS = {
    5364, # Recipe: Sealed Dark Crystal Shield (60%)
    5366, # Recipe: Sealed Shield of Nightmare (60%)
    6329, # Recipe: Sealed Phoenix Necklace (70%)
    6331, # Recipe: Sealed Phoenix Earring (70%)
    6333, # Recipe: Sealed Phoenix Ring (70%)
    6335, # Recipe: Sealed Majestic Necklace (70%)
    6337, # Recipe: Sealed Majestic Earring (70%)
    6339, # Recipe: Sealed Majestic Ring (70%)
  }
  # Mobs
  private MOBS = {
    20672 => 0.71, # trives
    20673 => 0.74  # falibati
  }

  def initialize
    super(358, self.class.simple_name, "Illegitimate Child of the Goddess")

    add_start_npc(OLTRAN)
    add_talk_id(OLTRAN)
    add_kill_id(MOBS.keys)
    register_quest_items(SNAKE_SCALE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    case event
    when "30862-02.htm", "30862-03.htm"
      event
    when "30862-04.htm"
      st.start_quest
      event
    end
  end

  def on_kill(npc, pc, is_summon)
    st = get_random_party_member_state(pc, 1, 3, npc)
    if st && st.give_item_randomly(npc, SNAKE_SCALE, 1, SNAKE_SCALE_COUNT, MOBS[npc.id], true)
      st.set_cond(2, true)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      html = pc.level >= MIN_LEVEL ? "30862-01.htm" : "30862-05.html"
    elsif st.started?
      if get_quest_items_count(pc, SNAKE_SCALE) < SNAKE_SCALE_COUNT
        html = "30862-06.html"
      else
        reward_items(pc, REWARDS.sample(random: Rnd), 1)
        st.exit_quest(true, true)
        html = "30862-07.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
