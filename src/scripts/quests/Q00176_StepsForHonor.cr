class Scripts::Q00176_StepsForHonor < Quest
  # NPC
  private RAPIDUS = 36479
  # Item
  private CLOAK = 14603
  # Misc
  private MIN_LEVEL = 80

  def initialize
    super(176, self.class.simple_name, "Steps for Honor")

    add_start_npc(RAPIDUS)
    add_talk_id(RAPIDUS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    if event.casecmp?("36479-04.html")
      st.start_quest
      return event
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "36479-03.html" : "36479-02.html"
    when State::STARTED
      if TerritoryWarManager.tw_in_progress?
        return "36479-05.html"
      end

      case st.cond
      when 1
        html = "36479-06.html"
      when 2
        st.set_cond(3, true)
        html = "36479-07.html"
      when 3
        html = "36479-08.html"
      when 4
        st.set_cond(5, true)
        html = "36479-09.html"
      when 5
        html = "36479-10.html"
      when 6
        st.set_cond(7, true)
        html = "36479-11.html"
      when 7
        html = "36479-12.html"
      when 8
        st.give_items(CLOAK, 1)
        st.exit_quest(false, true)
        html = "36479-13.html"
      end
    when State::COMPLETED
      html = "36479-01.html"
    end

    html || get_no_quest_msg(pc)
  end
end
