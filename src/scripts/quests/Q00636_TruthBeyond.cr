class Scripts::Q00636_TruthBeyond < Quest
  private ELIYAH = 31329
  private FLAURON = 32010
  private ZONE = 30100
  private VISITOR_MARK = 8064
  private FADED_MARK = 8065
  private MARK = 8067

  def initialize
    super(636, self.class.simple_name, "The Truth Beyond the Gate")

    add_start_npc(ELIYAH)
    add_talk_id(ELIYAH, FLAURON)
    add_enter_zone_id(ZONE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if event == "31329-04.htm"
      st.start_quest
    elsif event == "32010-02.htm"
      st.give_items(VISITOR_MARK, 1)
      st.exit_quest(true, true)
    end

    event
  end

  def on_enter_zone(char, zone)
    if char.is_a?(L2PcInstance)
      if char.destroy_item_by_item_id("Mark", VISITOR_MARK, 1, char, false)
        char.add_item("Mark", FADED_MARK, 1, char, true)
      end
    end

    nil
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    if npc.id == ELIYAH
      if st.has_quest_items?(VISITOR_MARK) || st.has_quest_items?(FADED_MARK) || st.has_quest_items?(MARK)
        st.exit_quest(true)
        return "31329-mark.htm"
      end
      if st.state == State::CREATED
        if pc.level > 72
          return "31329-02.htm"
        end

        st.exit_quest(true)
        return "31329-01.htm"
      elsif st.state == State::STARTED
        return "31329-05.htm"
      end
    elsif st.state == State::STARTED # Flauron only
      if st.cond?(1)
        return "32010-01.htm"
      end
      st.exit_quest(true)
      return "32010-03.htm"
    end

    get_no_quest_msg(pc)
  end
end
