class Scripts::Q00359_ForASleeplessDeadman < Quest
  # NPC
  private ORVEN = 30857
  # Item
  private REMAINS_OF_ADEN_RESIDENTS = 5869
  # Misc
  private MIN_LEVEL = 60
  private REMAINS_COUNT = 60
  # Rewards
  private REWARDS = {
    5494, # Sealed Dark Crystal Shield Fragment
    5495, # Sealed Shield of Nightmare Fragment
    6341, # Sealed Phoenix Earring Gemstone
    6342, # Sealed Majestic Earring Gemstone
    6343, # Sealed Phoenix Necklace Beads
    6344, # Sealed Majestic Necklace Beads
    6345, # Sealed Phoenix Ring Gemstone
    6346, # Sealed Majestic Ring Gemstone
  }
  # Mobs
  private MOBS = {
    21006 => 0.365, # doom_servant
    21007 => 0.392, # doom_guard
    21008 => 0.503  # doom_archer
  }

  def initialize
    super(359, self.class.simple_name, "For a Sleepless Deadman")

    add_start_npc(ORVEN)
    add_talk_id(ORVEN)
    add_kill_id(MOBS.keys)
    register_quest_items(REMAINS_OF_ADEN_RESIDENTS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30857-02.htm", "30857-03.htm", "30857-04.htm"
      html = event
    when "30857-05.htm"
      st.memo_state = 1
      st.start_quest
      html = event
    when "30857-10.html"
      reward_items(pc, REWARDS.sample(random: Rnd), 4)
      st.exit_quest(true, true)
      html = event
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    st = get_random_party_member_state(pc, 1, 3, npc)
    if st && st.give_item_randomly(npc, REMAINS_OF_ADEN_RESIDENTS, 1, REMAINS_COUNT, MOBS[npc.id], true)
      st.set_cond(2, true)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      html = pc.level >= MIN_LEVEL ? "30857-01.htm" : "30857-06.html"
    elsif st.started?
      if st.memo_state?(1)
        if get_quest_items_count(pc, REMAINS_OF_ADEN_RESIDENTS) < REMAINS_COUNT
          html = "30857-07.html"
        else
          take_items(pc, REMAINS_OF_ADEN_RESIDENTS, -1)
          st.memo_state = 2
          st.set_cond(3, true)
          html = "30857-08.html"
        end
      elsif st.memo_state?(2)
        html = "30857-09.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
