class Scripts::Q00028_ChestCaughtWithABaitOfIcyAir < Quest
  # NPCs
  private OFULLE = 31572
  private KIKI = 31442
  # Items
  private YELLOW_TREASURE_BOX = 6503
  private KIKIS_LETTER = 7626
  private ELVEN_RING = 881

  def initialize
    super(28, self.class.simple_name, "Chest Caught With A Bait Of Icy Air")

    add_start_npc(OFULLE)
    add_talk_id(OFULLE, KIKI)
    register_quest_items(KIKIS_LETTER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return html
    end

    case event
    when "31572-04.htm"
      st.start_quest
    when "31572-08.htm"
      if st.cond?(1) && st.has_quest_items?(YELLOW_TREASURE_BOX)
        st.give_items(KIKIS_LETTER, 1)
        st.take_items(YELLOW_TREASURE_BOX, -1)
        st.set_cond(2, true)
        html = "31572-07.htm"
      end
    when "31442-03.htm"
      if st.cond?(2) && st.has_quest_items?(KIKIS_LETTER)
        st.give_items(ELVEN_RING, 1)
        st.exit_quest(false, true)
        html = "31442-02.htm"
      end
    else
      # [automatically added else]
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
      if npc_id == OFULLE
        if pc.level >= 36 && pc.quest_completed?(Q00051_OFullesSpecialBait.simple_name)
          html = "31572-01.htm"
        else
          html = "31572-02.htm"
        end
      end
    when State::STARTED
      case npc_id
      when OFULLE
        case st.cond
        when 1
          html = "31572-06.htm"
          if st.has_quest_items?(YELLOW_TREASURE_BOX)
            html = "31572-05.htm"
          end
        when 2
          html = "31572-09.htm"
        else
          # [automatically added else]
        end
      when KIKI
        if st.cond?(2)
          html = "31442-01.htm"
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
