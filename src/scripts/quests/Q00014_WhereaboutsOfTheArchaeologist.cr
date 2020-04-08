class Scripts::Q00014_WhereaboutsOfTheArchaeologist < Quest
  # NPCs
  private LIESEL = 31263
  private GHOST_OF_ADVENTURER = 31538
  # Item
  private LETTER = 7253

  def initialize
    super(14, self.class.simple_name, "Whereabouts of the Archaeologist")

    add_start_npc(LIESEL)
    add_talk_id(LIESEL, GHOST_OF_ADVENTURER)
    register_quest_items(LETTER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return html
    end

    case event
    when "31263-02.html"
      st.start_quest
      st.give_items(LETTER, 1)
    when "31538-01.html"
      if st.cond?(1) && st.has_quest_items?(LETTER)
        st.give_adena(136928, true)
        st.add_exp_and_sp(325881, 32524)
        st.exit_quest(false, true)
      else
        html = "31538-02.html"
      end
    else
      # automatically added
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
      if npc_id == LIESEL
        html = pc.level < 74 ? "31263-01.html" : "31263-00.htm"
      end
    when State::STARTED
      if st.cond?(1)
        case npc_id
        when LIESEL
          html = "31263-02.html"
        when GHOST_OF_ADVENTURER
          html = "31538-00.html"
        else
          # automatically added
        end

      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end