class Scripts::Q00043_HelpTheSister < Quest
  # NPCs
  private COOPER = 30829
  private GALLADUCCI = 30097
  # Monsters
  private SPECTER = 20171
  private SORROW_MAIDEN = 20197
  # Items
  private CRAFTED_DAGGER = 220
  private MAP_PIECE = 7550
  private MAP = 7551
  private PET_TICKET = 7584

  def initialize
    super(43, self.class.simple_name, "Help The Sister!")

    add_start_npc(COOPER)
    add_talk_id(COOPER, GALLADUCCI)
    add_kill_id(SORROW_MAIDEN, SPECTER)
    register_quest_items(MAP, MAP_PIECE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    html = event
    case event
    when "30829-01.htm"
      st.start_quest
    when "30829-03.html"
      if st.has_quest_items?(CRAFTED_DAGGER)
        st.take_items(CRAFTED_DAGGER, 1)
        st.set_cond(2, true)
      else
        html = get_no_quest_msg(pc)
      end
    when "30829-06.html"
      if st.get_quest_items_count(MAP_PIECE) == 30
        st.take_items(MAP_PIECE, -1)
        st.give_items(MAP, 1)
        st.set_cond(4, true)
      else
        html = "30829-06a.html"
      end
    when "30097-02.html"
      if st.has_quest_items?(MAP)
        st.take_items(MAP, -1)
        st.set_cond(5, true)
      else
        html = "30097-02a.html"
      end
    when "30829-09.html"
      st.give_items(PET_TICKET, 1)
      st.exit_quest(false, true)
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)

    if st && st.cond?(2)
      st.give_items(MAP_PIECE, 1)
      if st.get_quest_items_count(MAP_PIECE) == 30
        st.set_cond(3, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case npc.id
    when COOPER
      case st.state
      when State::CREATED
        html = pc.level >= 26 ? "30829-00.htm" : "30829-00a.html"
      when State::STARTED
        case st.cond
        when 1
          if st.has_quest_items?(CRAFTED_DAGGER)
            html = "30829-02.html"
          else
            html = "30829-02a.html"
          end
        when 2
          html = "30829-04.html"
        when 3
          html = "30829-05.html"
        when 4
          html = "30829-07.html"
        when 5
          html = "30829-08.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when GALLADUCCI
      if st.started?
        case st.cond
        when 4
          html = "30097-01.html"
        when 5
          html = "30097-03.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
