class Scripts::Q00164_BloodFiend < Quest
  # NPC
  private CREAMEES = 30149
  # Monster
  private KIRUNAK = 27021
  # Item
  private KIRUNAK_SKULL = 1044
  # Misc
  private MIN_LVL = 21

  def initialize
    super(164, self.class.simple_name, "Blood Fiend")

    add_start_npc(CREAMEES)
    add_talk_id(CREAMEES)
    add_kill_id(KIRUNAK)
    register_quest_items(KIRUNAK_SKULL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event == "30149-04.htm"
      st.start_quest
      return event
    end

    nil
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1)
      npc.broadcast_packet(NpcSay.new(npc, Say2::ALL, NpcString::I_HAVE_FULFILLED_MY_CONTRACT_WITH_TRADER_CREAMEES))
      st.give_items(KIRUNAK_SKULL, 1)
      st.set_cond(2, true)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if !pc.race.dark_elf?
        if pc.level >= MIN_LVL
          html = "30149-03.htm"
        else
          html = "30149-02.htm"
        end
      else
        html = "30149-00.htm"
      end
    when State::STARTED
      if st.cond?(2) && st.has_quest_items?(KIRUNAK_SKULL)
        st.give_adena(42_130, true)
        st.add_exp_and_sp(35_637, 1854)
        st.exit_quest(false, true)
        html = "30149-06.html"
      else
        html = "30149-05.html"
      end
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    end

    html || get_no_quest_msg(pc)
  end
end
