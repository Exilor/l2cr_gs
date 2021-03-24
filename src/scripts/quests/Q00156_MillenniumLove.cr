class Scripts::Q00156_MillenniumLove < Quest
  # NPCs
  private LILITH = 30368
  private BAENEDES = 30369
  # Items
  private LILITHS_LETTER = 1022
  private THEONS_DIARY = 1023
  private GREATER_COMP_SOULSHOUT_PACKAGE_NO_GRADE = 5250
  # Misc
  private MIN_LVL = 15

  def initialize
    super(156, self.class.simple_name, "Millennium Love")

    add_start_npc(LILITH)
    add_talk_id(LILITH, BAENEDES)
    register_quest_items(LILITHS_LETTER, THEONS_DIARY)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)

    if st
      case event
      when "30368-02.html", "30368-03.html"
        html = event
      when "30368-05.htm"
        if pc.level >= MIN_LVL
          st.start_quest
          st.give_items(LILITHS_LETTER, 1)
          html = event
        else
          html = "30368-04.htm"
        end
      when "30369-02.html"
        if st.cond?(1) && st.has_quest_items?(LILITHS_LETTER)
          st.take_items(LILITHS_LETTER, 1)
          st.give_items(THEONS_DIARY, 1)
          st.set_cond(2, true)
          html = event
        end
      when "30369-03.html"
        if st.cond?(1) && st.has_quest_items?(LILITHS_LETTER)
          st.add_exp_and_sp(3000, 0)
          st.exit_quest(false, true)
          html = event
        end
      end
    end

    html
  end

  def on_talk(npc, pc)
    if st = get_quest_state(pc, true)
      case npc.id
      when LILITH
        case st.state
        when State::CREATED
          html = "30368-01.htm"
        when State::STARTED
          if st.cond?(1) && st.has_quest_items?(LILITHS_LETTER)
            html = "30368-06.html"
          elsif st.cond?(2) && st.has_quest_items?(THEONS_DIARY)
            st.give_items(GREATER_COMP_SOULSHOUT_PACKAGE_NO_GRADE, 1)
            st.add_exp_and_sp(3000, 0)
            st.exit_quest(false, true)
            html = "30368-07.html"
          end
        when State::COMPLETED
          html = get_already_completed_msg(pc)
        end
      when BAENEDES
        case st.cond
        when 1
          if st.has_quest_items?(LILITHS_LETTER)
            html = "30369-01.html"
          end
        when 2
          if st.has_quest_items?(THEONS_DIARY)
            html = "30369-04.html"
          end
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
