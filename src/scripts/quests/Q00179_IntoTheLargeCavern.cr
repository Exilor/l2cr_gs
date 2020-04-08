class Scripts::Q00179_IntoTheLargeCavern < Quest
  # NPCs
  private KEKROPUS = 32138
  private MENACING_MACHINE = 32258
  # Misc
  private MIN_LEVEL = 17
  private MAX_LEVEL = 21

  def initialize
    super(179, self.class.simple_name, "Into The Large Cavern")

    add_start_npc(KEKROPUS)
    add_talk_id(KEKROPUS, MENACING_MACHINE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && npc
    html = event
    return html unless st = get_quest_state(pc, false)

    if npc.id == KEKROPUS
      if event.casecmp?("32138-03.html")
        st.start_quest
      end
    elsif npc.id == MENACING_MACHINE
      if event.casecmp?("32258-08.html")
        st.give_items(391, 1)
        st.give_items(413, 1)
        st.exit_quest(false, true)
      elsif event.casecmp?("32258-09.html")
        st.give_items(847, 2)
        st.give_items(890, 2)
        st.give_items(910, 1)
        st.exit_quest(false, true)
      end
    end

    html
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    if npc.id == KEKROPUS
      case st.state
      when State::CREATED
        if !pc.race.kamael?
          html = "32138-00b.html"
        else
          prev = pc.quest_completed?(Q00178_IconicTrinity.simple_name)
          level = pc.level
          if prev && level.between?(MIN_LEVEL, MAX_LEVEL) && pc.class_id.level == 0
            html = "32138-01.htm"
          elsif level < MIN_LEVEL
            html = "32138-00.html"
          else
            html = "32138-00c.html"
          end
        end
      when State::STARTED
        if st.cond?(1)
          html = "32138-03.htm"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # automatically added
      end

    elsif npc.id == MENACING_MACHINE && st.state == State::STARTED
      html = "32258-01.html"
    end

    html
  end
end