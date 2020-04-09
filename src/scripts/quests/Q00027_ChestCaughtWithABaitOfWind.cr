class Scripts::Q00027_ChestCaughtWithABaitOfWind < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return html
    end

    case event
    when "31570-03.htm"
      st.start_quest
    when "31570-05.htm"
      if st.cond?(1) && st.has_quest_items?(BLUE_TREASURE_BOX)
        html = "31570-06.htm"
        st.set_cond(2, true)
        st.give_items(STRANGE_BLUESPRINT, 1)
        st.take_items(BLUE_TREASURE_BOX, -1)
      end
    when "31434-02.htm"
      if st.cond?(2) && st.has_quest_items?(STRANGE_BLUESPRINT)
        st.give_items(BLACK_PEARL_RING, 1)
        st.exit_quest(false, true)
        html = "31434-01.htm"
      end

    else
      # [automatically added else]
    end


    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::COMPLETED
      html = get_already_completed_msg(pc)
    when State::CREATED
      if npc.id == LANOSCO
        if pc.level >= 27 && pc.quest_completed?(Q00050_LanoscosSpecialBait.simple_name)
          html = "31570-01.htm"
        else
          html = "31570-02.htm"
        end
      end
    when State::STARTED
      case npc.id
      when LANOSCO
        if st.cond?(1)
          if st.has_quest_items?(BLUE_TREASURE_BOX)
            html = "31570-04.htm"
          else
            html = "31570-05.htm"
          end
        else
          html = "31570-07.htm"
        end
      when SHALING
        if st.cond?(2)
          html = "31434-00.htm"
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
