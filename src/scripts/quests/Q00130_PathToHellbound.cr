class Quests::Q00130_PathToHellbound < Quest
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

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return
    end

    case event
    when "30612-04.htm"
      htmltext = event
    when "32292-02.html"
      if st.cond?(1)
        htmltext = event
      end
    when "32292-06.html"
      if st.cond?(3)
        htmltext = event
      end
    when "30612-05.html"
      st.start_quest
      htmltext = event
    when "30612-08.html"
      if st.cond?(2)
        st.give_items(CASIANS_BLUE_CRYSTAL, 1)
        st.set_cond(3, true)
        htmltext = event
      end
    when "32292-03.html"
      if st.cond?(1)
        st.set_cond(2, true)
        htmltext = event
      end
    when "32292-07.html"
      if st.cond?(3) && st.has_quest_items?(CASIANS_BLUE_CRYSTAL)
        st.exit_quest(false, true)
        htmltext = event
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    unless st = get_quest_state!(player)
      return get_no_quest_msg(player)
    end

    case st.state
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    when State::CREATED
      if npc.id == CASIAN
        if !HellboundEngine.locked?
          if player.level >= MIN_LEVEL
            htmltext = "30612-01.htm"
          else
            htmltext = "30612-02.html"
          end
        else
          htmltext = "30612-03.html"
        end
      end
    when State::STARTED
      if npc.id == CASIAN
        case st.cond
        when 1
          htmltext = "30612-06.html"
        when 2
          htmltext = "30612-07.html"
        when 3
          htmltext = "30612-09.html"
        end
      elsif npc.id == GALATE
        case st.cond
        when 1
          htmltext = "32292-01.html"
        when 2
          htmltext = "32292-04.html"
        when 3
          htmltext = "32292-05.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
