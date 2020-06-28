class Scripts::Q00012_SecretMeetingWithVarkaSilenos < Quest
  # NPCs
  private CADMON = 31296
  private HELMUT = 31258
  private NARAN_NARAN_ASHANUK  = 31378
  # Item
  private MUNITIONS_BOX = 7232

  private MIN_LEVEL = 74

  def initialize
    super(12, self.class.simple_name, "Secret Meeting With Varka Silenos")

    add_start_npc(CADMON)
    add_talk_id(CADMON, HELMUT, NARAN_NARAN_ASHANUK)
    register_quest_items(MUNITIONS_BOX)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    case event
    when "31296-03.htm"
      st.start_quest
      st.memo_state = 11
      event
    when "31258-02.html"
      give_items(pc, MUNITIONS_BOX, 1)
      st.memo_state = 21
      st.set_cond(2, true)
      event
    when "31378-02.html"
      if has_quest_items?(pc, MUNITIONS_BOX)
        add_exp_and_sp(pc, 233125, 18142)
        st.exit_quest(false, true)
        event
      else
        "31378-03.html"
      end
    end
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if npc.id == CADMON
        html = pc.level >= MIN_LEVEL ? "31296-01.htm" : "31296-02.html"
      end
    when State::STARTED
      if npc.id == CADMON
        if st.memo_state?(11)
          html = "31296-04.html"
        end
      elsif npc.id == HELMUT
        if st.memo_state?(11)
          html = "31258-01.html"
        elsif st.memo_state?(21)
          html = "31258-03.html"
        end
      elsif npc.id == NARAN_NARAN_ASHANUK && st.memo_state?(21)
        if has_quest_items?(pc, MUNITIONS_BOX)
          html = "31378-01.html"
        end
      end
    when State::COMPLETED
      if npc.id == CADMON
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
