class Quests::Q00363_SorrowfulSoundOfFlute < Quest
  # NPCs
  private ALDO = 30057
  private HOLVAS = 30058
  private POITAN = 30458
  private RANSPO = 30594
  private OPIX = 30595
  private NANARIN = 30956
  private BARBADO = 30959
  # Items
  private EVENT_CLOTHES = 4318
  private NANARINS_FLUTE = 4319
  private SABRINS_BLACK_BEER = 4320
  private THEME_OF_SOLITUDE = 4420
  # Misc
  private MIN_LEVEL = 15

  def initialize
    super(363, self.class.simple_name, "Sorrowful Sound of Flute")

    add_start_npc(NANARIN)
    add_talk_id(NANARIN, POITAN, RANSPO, ALDO, HOLVAS, OPIX, BARBADO)
    register_quest_items(EVENT_CLOTHES, NANARINS_FLUTE, SABRINS_BLACK_BEER)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "START"
      if pc.level >= MIN_LEVEL
        st.start_quest
        st.memo_state = 2
        html = "30956-02.htm"
      else
        html = "30956-03.htm"
      end
    when "30956-05.html"
      st.give_items(EVENT_CLOTHES, 1)
      st.memo_state = 4
      st.set_cond(3, true)
      html = event
    when "30956-06.html"
      st.give_items(NANARINS_FLUTE, 1)
      st.memo_state = 4
      st.set_cond(3, true)
      html = event
    when "30956-07.html"
      st.give_items(SABRINS_BLACK_BEER, 1)
      st.memo_state = 4
      st.set_cond(3, true)
      html = event
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if npc.id == NANARIN
        html = "30956-01.htm"
      end
    when State::STARTED
      case npc.id
      when NANARIN
        case st.memo_state
        when 2
          html = "30956-04.html"
        when 4
          html = "30956-08.html"
        when 5
          st.reward_items(THEME_OF_SOLITUDE, 1)
          st.exit_quest(true, true)
          html = "30956-09.html"
        when 6
          st.exit_quest(true, false)
          st.play_sound(Sound::ITEMSOUND_QUEST_GIVEUP)
          html = "30956-10.html"
        end
      when POITAN
        if st.memo_state?(2) && st.get_int("ex") % 100 < 10
          ex = st.get_int("ex")
          st.set("ex", ex + 11)
          case rand(3)
          when 0
            html = "30458-01.html"
          when 1
            html = "30458-02.html"
          when 2
            html = "30458-03.html"
          end

          st.set_cond(2, true)
        elsif st.memo_state >= 2 && st.get_int("ex") % 100 >= 10
          html = "30458-04.html"
        end
      when RANSPO
        if st.memo_state?(2) && st.get_int("ex") % 10000 < 1000
          ex = st.get_int("ex")
          st.set("ex", ex + 1001)
          case rand(3)
          when 0
            html = "30594-01.html"
          when 1
            html = "30594-02.html"
          when 2
            html = "30594-03.html"
          end

          st.set_cond(2, true)
        elsif st.memo_state >= 2 && st.get_int("ex") % 10000 >= 1000
          html = "30594-04.html"
        end
      when ALDO
        if st.memo_state?(2) && st.get_int("ex") % 100000 < 10000
          ex = st.get_int("ex")
          st.set("ex", ex + 10001)
          case rand(3)
          when 0
            html = "30057-01.html"
          when 1
            html = "30057-02.html"
          when 2
            html = "30057-03.html"
          end

          st.set_cond(2, true)
        elsif st.memo_state >= 2 && st.get_int("ex") % 100000 >= 10000
          html = "30057-04.html"
        end
      when HOLVAS
        if st.memo_state?(2) && st.get_int("ex") % 1000 < 100
          ex = st.get_int("ex")
          st.set("ex", ex + 101)
          case rand(3)
          when 0
            html = "30058-01.html"
          when 1
            html = "30058-02.html"
          when 2
            html = "30058-03.html"
          end

          st.set_cond(2, true)
        elsif st.memo_state >= 2 && st.get_int("ex") % 1000 >= 100
          html = "30058-04.html"
        end
      when OPIX
        if st.memo_state?(2) && st.get_int("ex") < 100000
          ex = st.get_int("ex")
          st.set("ex", ex + 100001)
          case rand(3)
          when 0
            html = "30595-01.html"
          when 1
            html = "30595-02.html"
          when 2
            html = "30595-03.html"
          end

          st.set_cond(2, true)
        elsif st.memo_state >= 2 && st.get_int("ex") >= 100000
          html = "30595-04.html"
        end
      when BARBADO
        if st.memo_state?(4)
          ex = (st.get_int("ex") % 10) * 20
          if rand(100) < ex
            if st.has_quest_items?(EVENT_CLOTHES)
              st.take_items(EVENT_CLOTHES, -1)
            elsif st.has_quest_items?(NANARINS_FLUTE)
              st.take_items(NANARINS_FLUTE, -1)
            elsif st.has_quest_items?(SABRINS_BLACK_BEER)
              st.take_items(SABRINS_BLACK_BEER, -1)
            end
            st.memo_state = 5
            st.set_cond(4, true)
            html = "30959-01.html"
          else
            st.memo_state = 6
            st.set_cond(4, true)
            html = "30959-02.html"
          end
        elsif st.memo_state >= 5
          html = "30959-03.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
