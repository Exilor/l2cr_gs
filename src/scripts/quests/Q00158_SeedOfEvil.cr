class Scripts::Q00158_SeedOfEvil < Quest
  # NPC
  private BIOTIN = 30031
  # Monster
  private NERKAS = 27016
  # Items
  private ENCHANT_ARMOR_D = 956
  private CLAY_TABLET = 1025
  # Misc
  private MIN_LEVEL = 21

  def initialize
    super(158, self.class.simple_name, "Seed of Evil")

    add_start_npc(BIOTIN)
    add_talk_id(BIOTIN)
    add_attack_id(NERKAS)
    add_kill_id(NERKAS)
    register_quest_items(CLAY_TABLET)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event.casecmp?("30031-03.htm")
      st.start_quest
      return event
    end

    nil
  end

  def on_attack(npc, attacker, damage, is_summon)
    if npc.script_value?(0)
      npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::HOW_DARE_YOU_CHALLENGE_ME))
      npc.script_value = 1
    end

    super
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && !st.has_quest_items?(CLAY_TABLET)
      st.give_items(CLAY_TABLET, 1)
      st.set_cond(2, true)
    end
    npc.broadcast_packet(NpcSay.new(npc, Say2::NPC_ALL, NpcString::THE_POWER_OF_LORD_BELETH_RULES_THE_WHOLE_WORLD))
    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "30031-02.htm" : "30031-01.html"
    when State::STARTED
      if st.cond?(1)
        html = "30031-04.html"
      elsif st.cond?(2) && st.has_quest_items?(CLAY_TABLET)
        st.give_items(ENCHANT_ARMOR_D, 1)
        st.add_exp_and_sp(17818, 927)
        st.give_adena(1495, true)
        st.exit_quest(false, true)
        html = "30031-05.html"
      end
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end