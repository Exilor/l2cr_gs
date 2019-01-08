class Quests::Q00015_SweetWhispers < Quest
  # NPCs
  private VLADIMIR = 31302
  private HIERARCH = 31517
  private M_NECROMANCER = 31518

  def initialize
    super(15, self.class.simple_name, "Sweet Whispers")

    add_start_npc(VLADIMIR)
    add_talk_id(VLADIMIR, HIERARCH, M_NECROMANCER)
  end

  def on_adv_event(event, npc, player)
    return unless player
    htmltext = event
    st = get_quest_state(player, false)
    unless st
      return htmltext
    end

    case event
    when "31302-01.html"
      st.start_quest
    when "31518-01.html"
      if st.cond?(1)
        st.set_cond(2)
      end
    when "31517-01.html"
      if st.cond?(2)
        st.add_exp_and_sp(350531, 28204)
        st.exit_quest(false, true)
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    htmltext = get_no_quest_msg(player)
    st = get_quest_state(player, true)
    unless st
      return htmltext
    end

    npc_id = npc.id

    case st.state
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    when State::CREATED
      if npc_id == VLADIMIR
        htmltext = player.level >= 60 ? "31302-00.htm" : "31302-00a.html"
      end
    when State::STARTED
      case npc_id
      when VLADIMIR
        if st.cond?(1)
          htmltext = "31302-01a.html"
        end
      when M_NECROMANCER
        case st.cond
        when 1
          htmltext = "31518-00.html"
        when 2
          htmltext = "31518-01a.html"
        end
      when HIERARCH
        if st.cond?(2)
          htmltext = "31517-00.html"
        end
      end
    end

    htmltext
  end
end
