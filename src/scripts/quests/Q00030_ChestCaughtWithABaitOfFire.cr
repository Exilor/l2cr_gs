class Quests::Q00030_ChestCaughtWithABaitOfFire < Quest
  # NPCs
  private LINNAEUS = 31577
  private RUKAL = 30629
  # Items
  private RED_TREASURE_BOX = 6511
  private RUKAL_MUSICAL = 7628
  private PROTECTION_NECKLACE = 916

  def initialize
    super(30, self.class.simple_name, "Chest Caught With A Bait Of Fire")

    add_start_npc(LINNAEUS)
    add_talk_id(LINNAEUS, RUKAL)
    register_quest_items(RUKAL_MUSICAL)
  end

  def on_adv_event(event, npc, player)
    return unless player
    htmltext = event
    unless st = get_quest_state(player, false)
      return htmltext
    end

    case event
    when "31577-02.htm"
      st.start_quest
    when "31577-04a.htm"
      if st.cond?(1) && st.has_quest_items?(RED_TREASURE_BOX)
        st.give_items(RUKAL_MUSICAL, 1)
        st.take_items(RED_TREASURE_BOX, -1)
        st.set_cond(2, true)
        htmltext = "31577-04.htm"
      end
    when "30629-02.htm"
      if st.cond?(2) && st.has_quest_items?(RUKAL_MUSICAL)
        st.give_items(PROTECTION_NECKLACE, 1)
        st.exit_quest(false, true)
        htmltext = "30629-03.htm"
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
      if npc_id == LINNAEUS
        if player.level >= 61 && player.quest_completed?(Q00053_LinnaeusSpecialBait.simple_name)
          htmltext = "31577-01.htm"
        else
          htmltext = "31577-00.htm"
        end
      end
    when State::STARTED
      case npc_id
      when LINNAEUS
        case st.cond
        when 1
          htmltext = "31577-03a.htm"
          if st.has_quest_items?(RED_TREASURE_BOX)
            htmltext = "31577-03.htm"
          end
        when 2
          htmltext = "31577-05.htm"
        end
      when RUKAL
        if st.cond?(2)
          htmltext = "30629-01.htm"
        end
      end
    end

    htmltext
  end
end
