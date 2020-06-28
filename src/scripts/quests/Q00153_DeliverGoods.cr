class Scripts::Q00153_DeliverGoods < Quest
  private MIN_LVL = 2
  # NPCs
  private JACKSON_ID = 30002
  private SILVIA_ID = 30003
  private ARNOLD_ID = 30041
  private RANT_ID = 30054
  # Items
  private DELIVERY_LIST_ID = 1012
  private HEAVY_WOOD_BOX_ID = 1013
  private CLOTH_BUNDLE_ID = 1014
  private CLAY_POT_ID = 1015
  private JACKSONS_RECEIPT_ID = 1016
  private SILVIAS_RECEIPT_ID = 1017
  private RANTS_RECEIPT_ID = 1018
  # Rewards
  private SOULSHOT_NO_GRADE_ID = 1835 # You get 3 Soulshots no grade.
  private RING_OF_KNOWLEDGE_ID = 875
  private XP_REWARD_AMOUNT = 600i64

  def initialize
    super(153, self.class.simple_name, "Deliver Goods")

    add_start_npc(ARNOLD_ID)
    add_talk_id(JACKSON_ID, SILVIA_ID, ARNOLD_ID, RANT_ID)
    register_quest_items(
      DELIVERY_LIST_ID, HEAVY_WOOD_BOX_ID, CLOTH_BUNDLE_ID, CLAY_POT_ID,
      JACKSONS_RECEIPT_ID, SILVIAS_RECEIPT_ID, RANTS_RECEIPT_ID
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && npc
    st = get_quest_state(pc, false)
    if st && npc.id == ARNOLD_ID
      if event.casecmp?("30041-02.html")
        st.start_quest
        st.give_items(DELIVERY_LIST_ID, 1)
        st.give_items(HEAVY_WOOD_BOX_ID, 1)
        st.give_items(CLOTH_BUNDLE_ID, 1)
        st.give_items(CLAY_POT_ID, 1)
      end
    end

    event
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    if npc.id == ARNOLD_ID
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LVL ? "30041-01.htm" : "30041-00.htm"
      when State::STARTED
        if st.cond?(1)
          html = "30041-03.html"
        elsif st.cond?(2)
          st.take_items(DELIVERY_LIST_ID, -1)
          st.take_items(JACKSONS_RECEIPT_ID, -1)
          st.take_items(SILVIAS_RECEIPT_ID, -1)
          st.take_items(RANTS_RECEIPT_ID, -1)
          st.give_items(RING_OF_KNOWLEDGE_ID, 1)
          st.give_items(RING_OF_KNOWLEDGE_ID, 1)
          st.add_exp_and_sp(XP_REWARD_AMOUNT, 0)
          st.exit_quest(false)
          html = "30041-04.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end

    else
      case npc.id
      when JACKSON_ID
        if st.has_quest_items?(HEAVY_WOOD_BOX_ID)
          st.take_items(HEAVY_WOOD_BOX_ID, -1)
          st.give_items(JACKSONS_RECEIPT_ID, 1)
          html = "30002-01.html"
        else
          html = "30002-02.html"
        end
      when SILVIA_ID
        if st.has_quest_items?(CLOTH_BUNDLE_ID)
          st.take_items(CLOTH_BUNDLE_ID, -1)
          st.give_items(SILVIAS_RECEIPT_ID, 1)
          st.give_items(SOULSHOT_NO_GRADE_ID, 3)
          html = "30003-01.html"
        else
          html = "30003-02.html"
        end
      when RANT_ID
        if st.has_quest_items?(CLAY_POT_ID)
          st.take_items(CLAY_POT_ID, -1)
          st.give_items(RANTS_RECEIPT_ID, 1)
          html = "30054-01.html"
        else
          html = "30054-02.html"
        end
      end


      if st.cond?(1) && st.has_quest_items?(JACKSONS_RECEIPT_ID)
        if st.has_quest_items?(SILVIAS_RECEIPT_ID)
          if st.has_quest_items?(RANTS_RECEIPT_ID)
            st.set_cond(2, true)
          end
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
