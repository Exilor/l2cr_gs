class Scripts::Q00015_SweetWhispers < Quest
  # NPCs
  private VLADIMIR = 31302
  private HIERARCH = 31517
  private M_NECROMANCER = 31518

  def initialize
    super(15, self.class.simple_name, "Sweet Whispers")

    add_start_npc(VLADIMIR)
    add_talk_id(VLADIMIR, HIERARCH, M_NECROMANCER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    st = get_quest_state(pc, false)
    unless st
      return html
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
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    npc_id = npc.id

    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      if npc_id == VLADIMIR
        html = pc.level >= 60 ? "31302-00.htm" : "31302-00a.html"
      end
    when State::STARTED
      case npc_id
      when VLADIMIR
        if st.cond?(1)
          html = "31302-01a.html"
        end
      when M_NECROMANCER
        case st.cond
        when 1
          html = "31518-00.html"
        when 2
          html = "31518-01a.html"
        else
          # [automatically added else]
        end

      when HIERARCH
        if st.cond?(2)
          html = "31517-00.html"
        end
      else
        # [automatically added else]
      end

    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
