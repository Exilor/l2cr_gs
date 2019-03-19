class Quests::Q00362_BardsMandolin < Quest
  # NPCs
  private WOODROW = 30837
  private NANARIN = 30956
  private SWAN = 30957
  private GALION = 30958
  # Items
  private SWANS_FLUTE = 4316
  private SWANS_LETTER = 4317
  private THEME_OF_JOURNEY = 4410
  # Misc
  private MIN_LEVEL = 15

  def initialize
    super(362, self.class.simple_name, "Bard's Mandolin")

    add_start_npc(SWAN)
    add_talk_id(SWAN, GALION, WOODROW, NANARIN)
    register_quest_items(SWANS_FLUTE, SWANS_LETTER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = nil
    case event
    when "30957-02.htm"
      st.start_quest
      st.memo_state = 1
      html = event
    when "30957-07.html", "30957-08.html"
      if st.memo_state?(5)
        st.give_adena(10000, true)
        st.reward_items(THEME_OF_JOURNEY, 1)
        st.exit_quest(true, true)
        html = event
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if npc.id == SWAN
        html = pc.level >= MIN_LEVEL ? "30957-01.htm" : "30957-03.html"
      end
    when State::STARTED
      case npc.id
      when SWAN
        case st.memo_state
        when 1, 2
          html = "30957-04.html"
        when 3
          st.set_cond(4, true)
          st.memo_state = 4
          st.give_items(SWANS_LETTER, 1)
          html = "30957-05.html"
        when 4
          html = "30957-05.html"
        when 5
          html = "30957-06.html"
        end
      when GALION
        if st.memo_state?(2)
          st.memo_state = 3
          st.set_cond(3, true)
          st.give_items(SWANS_FLUTE, 1)
          html = "30958-01.html"
        elsif st.memo_state >= 3
          html = "30958-02.html"
        end
      when WOODROW
        if st.memo_state?(1)
          st.memo_state = 2
          st.set_cond(2, true)
          html = "30837-01.html"
        elsif st.memo_state?(2)
          html = "30837-02.html"
        elsif st.memo_state >= 3
          html = "30837-03.html"
        end
      when NANARIN
        if st.memo_state?(4) && st.has_quest_items?(SWANS_FLUTE, SWANS_LETTER)
          st.memo_state = 5
          st.set_cond(5, true)
          st.take_items(SWANS_FLUTE, -1)
          st.take_items(SWANS_LETTER, -1)
          html = "30956-01.html"
        elsif st.memo_state >= 5
          html = "30956-02.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
