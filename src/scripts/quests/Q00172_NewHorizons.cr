class Scripts::Q00172_NewHorizons < Quest
  # NPCs
  private ZENYA = 32140
  private RAGARA = 32163

  # Items
  private SCROLL_OF_ESCAPE_GIRAN = 7559
  private MARK_OF_TRAVELER = 7570

  # Misc
  private MIN_LEVEL = 3

  def initialize
    super(172, self.class.simple_name, "New Horizons")

    add_start_npc(ZENYA)
    add_talk_id(ZENYA, RAGARA)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st.nil?
      return
    end

    html = event
    case event
    when "32140-04.htm"
      st.start_quest
    when "32163-02.html"
      st.give_items(SCROLL_OF_ESCAPE_GIRAN, 1)
      st.give_items(MARK_OF_TRAVELER, 1)
      st.exit_quest(false, true)
    else
      return
    end

    html
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when ZENYA
      case st.state
      when State::CREATED
        if pc.race.kamael?
          if pc.level >= MIN_LEVEL
            html = "32140-01.htm"
          else
            html = "32140-02.htm"
          end
        else
          html = "32140-03.htm"
        end
      when State::STARTED
        html = "32140-05.html"
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      else
        # [automatically added else]
      end

    when RAGARA
      if st.started?
        html = "32163-01.html"
      end
    else
      # [automatically added else]
    end


    html
  end
end
