class Scripts::Q00151_CureForFever < Quest
  # NPCs
  private ELLIAS = 30050
  private YOHANES = 30032
  # Monsters
  private MOBS = {
    20103, # Giant Spider
    20106, # Talon Spider
    20108  # Blade Spider
  }
  # Items
  private ROUND_SHIELD = 102
  private POISON_SAC = 703
  private FEVER_MEDICINE = 704
  # Misc
  private MIN_LEVEL = 15
  private CHANCE = 0

  def initialize
    super(151, self.class.simple_name, "Cure for Fever")

    add_start_npc(ELLIAS)
    add_talk_id(ELLIAS, YOHANES)
    add_kill_id(MOBS)
    register_quest_items(POISON_SAC, FEVER_MEDICINE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event.casecmp?("30050-03.htm")
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1) && Rnd.rand(5) == CHANCE
      st.give_items(POISON_SAC, 1)
      st.set_cond(2, true)
    end
    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when ELLIAS
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LEVEL ? "30050-02.htm" : "30050-01.htm"
      when State::STARTED
        if st.cond?(3) && st.has_quest_items?(FEVER_MEDICINE)
          st.give_items(ROUND_SHIELD, 1)
          st.add_exp_and_sp(13106, 613)
          st.exit_quest(false, true)
          show_on_screen_msg(pc, NpcString::LAST_DUTY_COMPLETE_N_GO_FIND_THE_NEWBIE_GUIDE, 2, 5000) # TODO: Newbie Guide
          html = "30050-06.html"
        elsif st.cond?(2) && st.has_quest_items?(POISON_SAC)
          html = "30050-05.html"
        else
          html = "30050-04.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when YOHANES
      if st.started?
        if st.cond?(2) && st.has_quest_items?(POISON_SAC)
          st.set_cond(3, true)
          st.take_items(POISON_SAC, -1)
          st.give_items(FEVER_MEDICINE, 1)
          html = "30032-01.html"
        elsif st.cond?(3) && st.has_quest_items?(FEVER_MEDICINE)
          html = "30032-02.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
