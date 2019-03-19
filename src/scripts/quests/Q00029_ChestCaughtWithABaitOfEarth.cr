class Quests::Q00029_ChestCaughtWithABaitOfEarth < Quest
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

  def on_adv_event(event, npc, player)
    return unless player
    htmltext = event
    unless st = get_quest_state(player, false)
      return htmltext
    end

    case event
    when "31574-04.htm"
      st.start_quest
    when "31574-08.htm"
      if st.cond?(1) && st.has_quest_items?(PURPLE_TREASURE_BOX)
        st.give_items(SMALL_GLASS_BOX, 1)
        st.take_items(PURPLE_TREASURE_BOX, -1)
        st.set_cond(2, true)
        htmltext = "31574-07.htm"
      end
    when "30909-03.htm"
      if st.cond?(2) && st.has_quest_items?(SMALL_GLASS_BOX)
        st.give_items(PLATED_LEATHER_GLOVES, 1)
        st.exit_quest(false, true)
        htmltext = "30909-02.htm"
      end

    end
    htmltext
  end

  def on_talk(npc, player)
    htmltext = get_no_quest_msg(player)
    st = get_quest_state!(player)
    npc_id = npc.id
    case st.state
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    when State::CREATED
      if npc_id == WILLIE
        htmltext = player.level >= 48 && player.quest_completed?(Q00052_WilliesSpecialBait.simple_name) ? "31574-01.htm" : "31574-02.htm"
      end
    when State::STARTED
      case npc_id
      when WILLIE
        case st.cond
        when 1
          htmltext = "31574-06.htm"
          if st.has_quest_items?(PURPLE_TREASURE_BOX)
            htmltext = "31574-05.htm"
          end
        when 2
          htmltext = "31574-09.htm"
        end
      when ANABEL
        if st.cond?(2)
          htmltext = "30909-01.htm"
        end
      end
    end

    htmltext
  end
end
