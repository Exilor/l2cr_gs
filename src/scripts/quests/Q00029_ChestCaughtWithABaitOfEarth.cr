class Scripts::Q00029_ChestCaughtWithABaitOfEarth < Quest
  # NPCs
  private WILLIE = 31574
  private ANABEL = 30909
  # Items
  private PURPLE_TREASURE_BOX = 6507
  private SMALL_GLASS_BOX = 7627
  private PLATED_LEATHER_GLOVES = 2455

  def initialize
    super(29, self.class.simple_name, "Chest Caught With A Bait Of Earth")

    add_start_npc(WILLIE)
    add_talk_id(WILLIE, ANABEL)
    register_quest_items(SMALL_GLASS_BOX)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return html
    end

    case event
    when "31574-04.htm"
      st.start_quest
    when "31574-08.htm"
      if st.cond?(1) && st.has_quest_items?(PURPLE_TREASURE_BOX)
        st.give_items(SMALL_GLASS_BOX, 1)
        st.take_items(PURPLE_TREASURE_BOX, -1)
        st.set_cond(2, true)
        html = "31574-07.htm"
      end
    when "30909-03.htm"
      if st.cond?(2) && st.has_quest_items?(SMALL_GLASS_BOX)
        st.give_items(PLATED_LEATHER_GLOVES, 1)
        st.exit_quest(false, true)
        html = "30909-02.htm"
      end

    else
      # automatically added
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    npc_id = npc.id
    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      if npc_id == WILLIE
        if pc.level >= 48 && pc.quest_completed?(Q00052_WilliesSpecialBait.simple_name)
          html = "31574-01.htm"
        else
          html = "31574-02.htm"
        end
      end
    when State::STARTED
      case npc_id
      when WILLIE
        case st.cond
        when 1
          html = "31574-06.htm"
          if st.has_quest_items?(PURPLE_TREASURE_BOX)
            html = "31574-05.htm"
          end
        when 2
          html = "31574-09.htm"
        else
          # automatically added
        end

      when ANABEL
        if st.cond?(2)
          html = "30909-01.htm"
        end
      else
        # automatically added
      end

    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end
end