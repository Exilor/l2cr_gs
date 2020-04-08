class Scripts::Q00030_ChestCaughtWithABaitOfFire < Quest
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

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return html
    end

    case event
    when "31577-02.htm"
      st.start_quest
    when "31577-04a.htm"
      if st.cond?(1) && st.has_quest_items?(RED_TREASURE_BOX)
        st.give_items(RUKAL_MUSICAL, 1)
        st.take_items(RED_TREASURE_BOX, -1)
        st.set_cond(2, true)
        html = "31577-04.htm"
      end
    when "30629-02.htm"
      if st.cond?(2) && st.has_quest_items?(RUKAL_MUSICAL)
        st.give_items(PROTECTION_NECKLACE, 1)
        st.exit_quest(false, true)
        html = "30629-03.htm"
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
      if npc_id == LINNAEUS
        if pc.level >= 61 && pc.quest_completed?(Q00053_LinnaeusSpecialBait.simple_name)
          html = "31577-01.htm"
        else
          html = "31577-00.htm"
        end
      end
    when State::STARTED
      case npc_id
      when LINNAEUS
        case st.cond
        when 1
          html = "31577-03a.htm"
          if st.has_quest_items?(RED_TREASURE_BOX)
            html = "31577-03.htm"
          end
        when 2
          html = "31577-05.htm"
        else
          # automatically added
        end

      when RUKAL
        if st.cond?(2)
          html = "30629-01.htm"
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