class Scripts::Q00130_PathToHellbound < Quest
  # NPCs
  private CASIAN = 30612
  private GALATE = 32292
  # Item
  private CASIANS_BLUE_CRYSTAL = 12823
  # Misc
  private MIN_LEVEL = 78

  def initialize
    super(130, self.class.simple_name, "Path To Hellbound")

    add_start_npc(CASIAN)
    add_talk_id(CASIAN, GALATE)
    register_quest_items(CASIANS_BLUE_CRYSTAL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30612-04.htm"
      html = event
    when "32292-02.html"
      if st.cond?(1)
        html = event
      end
    when "32292-06.html"
      if st.cond?(3)
        html = event
      end
    when "30612-05.html"
      st.start_quest
      html = event
    when "30612-08.html"
      if st.cond?(2)
        st.give_items(CASIANS_BLUE_CRYSTAL, 1)
        st.set_cond(3, true)
        html = event
      end
    when "32292-03.html"
      if st.cond?(1)
        st.set_cond(2, true)
        html = event
      end
    when "32292-07.html"
      if st.cond?(3) && st.has_quest_items?(CASIANS_BLUE_CRYSTAL)
        st.exit_quest(false, true)
        html = event
      end
    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    unless st = get_quest_state!(pc)
      return get_no_quest_msg(pc)
    end

    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      if npc.id == CASIAN
        if !HellboundEngine.instance.locked?
          if pc.level >= MIN_LEVEL
            html = "30612-01.htm"
          else
            html = "30612-02.html"
          end
        else
          html = "30612-03.html"
        end
      end
    when State::STARTED
      if npc.id == CASIAN
        case st.cond
        when 1
          html = "30612-06.html"
        when 2
          html = "30612-07.html"
        when 3
          html = "30612-09.html"
        else
          # [automatically added else]
        end

      elsif npc.id == GALATE
        case st.cond
        when 1
          html = "32292-01.html"
        when 2
          html = "32292-04.html"
        when 3
          html = "32292-05.html"
        else
          # [automatically added else]
        end

      end
    else
      # [automatically added else]
    end


    html || get_no_quest_msg(pc)
  end
end
