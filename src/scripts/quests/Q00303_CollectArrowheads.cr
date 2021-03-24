class Scripts::Q00303_CollectArrowheads < Quest
  # NPC
  private MINIA = 30029
  # Item
  private ORCISH_ARROWHEAD = 963
  # Misc
  private MIN_LEVEL = 10
  private REQUIRED_ITEM_COUNT = 10
  # Monster
  private TUNATH_ORC_MARKSMAN = 20361

  def initialize
    super(303, self.class.simple_name, "Collect Arrowheads")

    add_start_npc(MINIA)
    add_talk_id(MINIA)
    add_kill_id(TUNATH_ORC_MARKSMAN)
    register_quest_items(ORCISH_ARROWHEAD)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event == "30029-04.htm"
      st.start_quest
      event
    end
  end

  def on_kill(npc, pc, is_summon)
    party_member = get_random_party_member(pc, 1)
    if party_member
      st = get_quest_state(party_member, false).not_nil!
      if st.give_item_randomly(npc, ORCISH_ARROWHEAD, 1, REQUIRED_ITEM_COUNT, 0.4, true)
        st.set_cond(2)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "30029-03.htm" : "30029-02.htm"
    when State::STARTED
      case st.cond
      when 1
        if st.get_quest_items_count(ORCISH_ARROWHEAD) < REQUIRED_ITEM_COUNT
          html = "30029-05.html"
        end
      when 2
        if st.get_quest_items_count(ORCISH_ARROWHEAD) >= REQUIRED_ITEM_COUNT
          st.give_adena(1000, true)
          st.add_exp_and_sp(2000, 0)
          st.exit_quest(true, true)
          html = "30029-06.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
