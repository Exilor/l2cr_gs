class Scripts::Q00452_FindingtheLostSoldiers < Quest
  private JAKAN = 32773
  private TAG_ID = 15513
  private SOLDIER_CORPSES = {
    32769,
    32770,
    32771,
    32772
  }

  def initialize
    super(452, self.class.simple_name, "Finding the Lost Soldiers")

    add_start_npc(JAKAN)
    add_talk_id(JAKAN)
    add_talk_id(SOLDIER_CORPSES)
    register_quest_items(TAG_ID)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    npc = npc.not_nil!

    html = event

    if npc.id == JAKAN
      if event == "32773-3.htm"
        st.start_quest
      end
    else
      if st.cond?(1)
        if Rnd.rand(10) < 5
          st.give_items(TAG_ID, 1)
        else
          html = "corpse-3.html"
        end
        st.set_cond(2, true)
        npc.delete_me
      else
        html = "corpse-3.html"
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if npc.id == JAKAN
      case st.state
      when State::CREATED
        html = pc.level < 84 ? "32773-0.html" : "32773-1.htm"
      when State::STARTED
        if st.cond?(1)
          html = "32773-4.html"
        elsif st.cond?(2)
          html = "32773-5.html"
          st.take_items(TAG_ID, -1)
          st.give_adena(95200, true)
          st.add_exp_and_sp(435024, 50366)
          st.exit_quest(QuestType::DAILY, true)
        end
      when State::COMPLETED
        if st.now_available?
          st.state = State::CREATED
          html = pc.level < 84 ? "32773-0.html" : "32773-1.htm"
        else
          html = "32773-6.html"
        end
      end

    else
      if st.cond?(1)
        html = "corpse-1.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
