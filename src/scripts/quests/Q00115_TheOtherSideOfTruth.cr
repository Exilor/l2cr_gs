class Scripts::Q00115_TheOtherSideOfTruth < Quest
  # NPCs
  private MISA = 32018
  private RAFFORTY = 32020
  private ICE_SCULPTURE1 = 32021
  private KIER = 32022
  private ICE_SCULPTURE2 = 32077
  private ICE_SCULPTURE3 = 32078
  private ICE_SCULPTURE4 = 32079
  # Items
  private MISAS_LETTER = 8079
  private RAFFORTYS_LETTER = 8080
  private PIECE_OF_TABLET = 8081
  private REPORT_PIECE = 8082
  # Misc
  private MIN_LEVEL = 53

  def initialize
    super(115, self.class.simple_name, "The Other Side of Truth")

    add_start_npc(RAFFORTY)
    add_talk_id(
      RAFFORTY, MISA, KIER, ICE_SCULPTURE1, ICE_SCULPTURE2, ICE_SCULPTURE3,
      ICE_SCULPTURE4
    )
    register_quest_items(
      MISAS_LETTER, RAFFORTYS_LETTER, PIECE_OF_TABLET, REPORT_PIECE
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32020-02.html"
      st.start_quest
      html = event
    when "32020-07.html"
      if st.cond?(2)
        st.take_items(MISAS_LETTER, -1)
        st.set_cond(3, true)
        html = event
      end
    when "32020-05.html"
      if st.cond?(2)
        st.take_items(MISAS_LETTER, -1)
        st.exit_quest(true, true)
        html = event
      end
    when "32020-10.html"
      if st.cond?(3)
        st.set_cond(4, true)
        html = event
      end
    when "32020-11.html"
      if st.cond?(3)
        st.set_cond(4, true)
        html = event
      end
    when "32020-12.html"
      if st.cond?(3)
        st.exit_quest(true, true)
        html = event
      end
    when "32020-08.html", "32020-09.html", "32020-13.html", "32020-14.html"
      html = event
    when "32020-15.html"
      if st.cond?(4)
        st.set_cond(5, true)
        st.play_sound(Sound::AMBSOUND_WINGFLAP)
        html = event
      end
    when "32020-23.html"
      if st.cond?(9)
        st.set_cond(10, true)
        html = event
      end
    when "finish"
      if st.cond?(10)
        if st.has_quest_items?(PIECE_OF_TABLET)
          st.give_adena(115673, true)
          st.add_exp_and_sp(493595, 40442)
          st.exit_quest(false, true)
          html = "32020-25.html"
        else
          st.set_cond(11, true)
          html = "32020-26.html"
          st.play_sound(Sound::AMBSOUND_THUNDER)
        end
      end
    when "finish2"
      if st.cond?(10)
        if st.has_quest_items?(PIECE_OF_TABLET)
          st.give_adena(115673, true)
          st.add_exp_and_sp(493595, 40442)
          st.exit_quest(false, true)
          html = "32020-27.html"
        else
          st.set_cond(11, true)
          html = "32020-28.html"
          st.play_sound(Sound::AMBSOUND_THUNDER)
        end
      end
    when "32018-05.html"
      if st.cond?(6) && st.has_quest_items?(RAFFORTYS_LETTER)
        st.take_items(RAFFORTYS_LETTER, -1)
        st.set_cond(7, true)
        html = event
      end
    when "32022-02.html"
      if st.cond?(8)
        st.give_items(REPORT_PIECE, 1)
        st.set_cond(9, true)
        html = event
      end
    when "32021-02.html"
      case npc.not_nil!.id
      when ICE_SCULPTURE1
        if st.cond?(7) && st.get_int("ex") % 2 <= 1
          ex = st.get_int("ex")
          if ex == 6 || ex == 10 || ex == 12
            ex += 1
            st.set("ex", ex)
            st.give_items(PIECE_OF_TABLET, 1)
            html = event
          end
        end
      when ICE_SCULPTURE2
        if st.cond?(7) && st.get_int("ex") % 4 <= 1
          ex = st.get_int("ex")
          if ex == 5 || ex == 9 || ex == 12
            ex += 2
            st.set("ex", ex)
            st.give_items(PIECE_OF_TABLET, 1)
            html = event
          end
        end
      when ICE_SCULPTURE3
        if st.cond?(7) && st.get_int("ex") % 8 <= 3
          ex = st.get_int("ex")
          if ex == 3 || ex == 9 || ex == 10
            ex += 4
            st.set("ex", ex)
            st.give_items(PIECE_OF_TABLET, 1)
            html = event
          end
        end
      when ICE_SCULPTURE4
        if st.cond?(7) && st.get_int("ex") <= 7
          ex = st.get_int("ex")
          if ex == 3 || ex == 5 || ex == 6
            ex += 8
            st.set("ex", ex)
            st.give_items(PIECE_OF_TABLET, 1)
            html = event
          end
        end
      end
    when "32021-03.html"
      case npc.not_nil!.id
      when ICE_SCULPTURE1
        if st.cond?(7) && st.get_int("ex") % 2 <= 1
          ex = st.get_int("ex")
          if ex == 6 || ex == 10 || ex == 12
            ex += 1
            st.set("ex", ex)
            html = event
          end
        end
      when ICE_SCULPTURE2
        if st.cond?(7) && st.get_int("ex") % 4 <= 1
          ex = st.get_int("ex")
          if ex == 5 || ex == 9 || ex == 12
            ex += 2
            st.set("ex", ex)
            html = event
          end
        end
      when ICE_SCULPTURE3
        if st.cond?(7) && st.get_int("ex") % 8 <= 3
          ex = st.get_int("ex")
          if ex == 3 || ex == 9 || ex == 12
            ex += 4
            st.set("ex", ex)
            html = event
          end
        end
      when ICE_SCULPTURE4
        if st.cond?(7) && st.get_int("ex") <= 7
          ex = st.get_int("ex")
          if ex == 3 || ex == 5 || ex == 6
            ex += 8
            st.set("ex", ex)
            html = event
          end
        end
      end
    when "32021-06.html"
      case npc.not_nil!.id
      when ICE_SCULPTURE1
        if st.cond?(7) && st.get_int("ex") == 14
          st.set_cond(8)
          html = event
        end
      when ICE_SCULPTURE2
        if st.cond?(7) && st.get_int("ex") == 13
          st.set_cond(8)
          html = event
        end
      when ICE_SCULPTURE3
        if st.cond?(7) && st.get_int("ex") == 11
          st.set_cond(8)
          html = event
        end
      when ICE_SCULPTURE4
        if st.cond?(7) && st.get_int("ex") == 7
          st.set_cond(8)
          html = event
        end
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      if npc.id == RAFFORTY
        html = get_already_completed_msg(pc)
      end
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "32020-01.htm" : "32020-03.html"
    when State::STARTED
      case npc.id
      when RAFFORTY
        case st.cond
        when 1
          html = "32020-04.html"
        when 2
          if st.has_quest_items?(MISAS_LETTER)
            html = "32020-06.html"
          else
            html = "32020-05.html"
          end
        when 3
          html = "32020-16.html"
        when 4
          html = "32020-17.html"
        when 5
          st.give_items(RAFFORTYS_LETTER, 1)
          st.set_cond(6, true)
          html = "32020-18.html"
        when 6
          if st.has_quest_items?(RAFFORTYS_LETTER)
            html = "32020-19.html"
          else
            st.give_items(RAFFORTYS_LETTER, 1)
            html = "32020-20.html"
          end
        when 7, 8
          html = "32020-21.html"
        when 9
          if st.has_quest_items?(REPORT_PIECE)
            html = "32020-22.html"
          end
        when 10
          html = "32020-24.html"
        when 11
          if !st.has_quest_items?(PIECE_OF_TABLET)
            html = "32020-29.html"
          else
            st.give_adena(115673, true)
            st.add_exp_and_sp(493595, 40442)
            st.exit_quest(false, true)
            html = "32020-30.html"
          end
        end
      when MISA
        case st.cond
        when 1
          st.give_items(MISAS_LETTER, 1)
          st.set_cond(2, true)
          html = "32018-01.html"
        when 2
          html = "32018-02.html"
        when 3, 4
          html = "32018-03.html"
        when 5, 6
          if st.has_quest_items?(RAFFORTYS_LETTER)
            html = "32018-04.html"
          end
        when 7
          html = "32018-06.html"
        end
      when KIER
        case st.cond
        when 8
          html = "32022-01.html"
        when 9
          if st.has_quest_items?(REPORT_PIECE)
            html = "32022-03.html"
          else
            st.give_items(REPORT_PIECE, 1)
            html = "32022-04.html"
          end
        when 11
          unless st.has_quest_items?(REPORT_PIECE)
            html = "32022-05.html"
          end
        end
      when ICE_SCULPTURE1
        case st.cond
        when 7
          if st.get_int("ex") % 2 <= 1
            ex = st.get_int("ex")
            if ex == 6 || ex == 10 || ex == 12
              html = "32021-01.html"
            elsif ex == 14
              html = "32021-05.html"
            else
              ex += 1
              st.set("ex", ex)
              html = "32021-07.html"
            end
          else
            html = "32021-04.html"
          end
        when 8
          html = "32021-08.html"
        when 11
          if !st.has_quest_items?(PIECE_OF_TABLET)
            st.give_items(PIECE_OF_TABLET, 1)
            html = "32021-09.html"
          else
            html = "32021-10.html"
          end
        end
      when ICE_SCULPTURE2
        case st.cond
        when 7
          if st.get_int("ex") % 4 <= 1
            ex = st.get_int("ex")
            if ex == 5 || ex == 9 || ex == 12
              html = "32021-01.html"
            elsif ex == 13
              html = "32021-05.html"
            else
              ex += 2
              st.set("ex", ex)
              html = "32021-07.html"
            end
          else
            html = "32021-04.html"
          end
        when 8
          html = "32021-08.html"
        when 11
          if !st.has_quest_items?(PIECE_OF_TABLET)
            st.give_items(PIECE_OF_TABLET, 1)
            html = "32021-09.html"
          else
            html = "32021-10.html"
          end
        end
      when ICE_SCULPTURE3
        case st.cond
        when 7
          if st.get_int("ex") % 8 <= 3
            ex = st.get_int("ex")
            if ex == 3 || ex == 9 || ex == 10
              html = "32021-01.html"
            elsif ex == 11
              html = "32021-05.html"
            else
              ex += 4
              st.set("ex", ex)
              html = "32021-07.html"
            end
          else
            html = "32021-04.html"
          end
        when 8
          html = "32021-08.html"
        when 11
          if !st.has_quest_items?(PIECE_OF_TABLET)
            st.give_items(PIECE_OF_TABLET, 1)
            html = "32021-09.html"
          else
            html = "32021-10.html"
          end
        end
      when ICE_SCULPTURE4
        case st.cond
        when 7
          if st.get_int("ex") <= 7
            ex = st.get_int("ex")
            if ex == 3 || ex == 5 || ex == 6
              html = "32021-01.html"
            elsif ex == 7
              html = "32021-05.html"
            else
              ex += 8
              st.set("ex", ex)
              html = "32021-07.html"
            end
          else
            html = "32021-04.html"
          end
        when 8
          html = "32021-08.html"
        when 11
          if !st.has_quest_items?(PIECE_OF_TABLET)
            st.give_items(PIECE_OF_TABLET, 1)
            html = "32021-09.html"
          else
            html = "32021-10.html"
          end
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
