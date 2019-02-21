class Quests::Q00027_ChestCaughtWithABaitOfWind < Quest
  # NPCs
  private LANOSCO = 31570
  private SHALING = 31434
  # Items
  private BLUE_TREASURE_BOX = 6500
  private STRANGE_BLUESPRINT = 7625
  private BLACK_PEARL_RING = 880

  def initialize
    super(27, self.class.simple_name, "Chest Caught With A Bait Of Wind")

    add_start_npc(LANOSCO)
    add_talk_id(LANOSCO, SHALING)
    register_quest_items(STRANGE_BLUESPRINT)
  end

  def on_adv_event(event, npc, player)
    return unless player
    htmltext = event
    return htmltext unless st = get_quest_state(player, false)

    case event
    when "31570-03.htm"
      st.start_quest
    when "31570-05.htm"
      if st.cond?(1) && st.has_quest_items?(BLUE_TREASURE_BOX)
        htmltext = "31570-06.htm"
        st.set_cond(2, true)
        st.give_items(STRANGE_BLUESPRINT, 1)
        st.take_items(BLUE_TREASURE_BOX, -1)
      end
    when "31434-02.htm"
      if st.cond?(2) && st.has_quest_items?(STRANGE_BLUESPRINT)
        st.give_items(BLACK_PEARL_RING, 1)
        st.exit_quest(false, true)
        htmltext = "31434-01.htm"
      end

    end

    htmltext
  end

  def on_talk(npc, player)
    htmltext = get_no_quest_msg(player)
    st = get_quest_state!(player)
    case st.state
    when State::COMPLETED
      htmltext = get_already_completed_msg(player)
    when State::CREATED
      if npc.id == LANOSCO
        if player.level >= 27 && player.quest_completed?(Q00050_LanoscosSpecialBait.simple_name)
          htmltext = "31570-01.htm"
        else
          htmltext = "31570-02.htm"
        end
      end
    when State::STARTED
      case npc.id
      when LANOSCO
        if st.cond?(1)
          if st.has_quest_items?(BLUE_TREASURE_BOX)
            htmltext = "31570-04.htm"
          else
            htmltext = "31570-05.htm"
          end
        else
          htmltext = "31570-07.htm"
        end
      when SHALING
        if st.cond?(2)
          htmltext = "31434-00.htm"
        end
      end
    end

    htmltext
  end
end
