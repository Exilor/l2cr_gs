class Scripts::Q00031_SecretBuriedInTheSwamp < Quest
  # NPCs
  private ABERCROMBIE = 31555
  private FORGOTTEN_MONUMENT_1 = 31661
  private FORGOTTEN_MONUMENT_2 = 31662
  private FORGOTTEN_MONUMENT_3 = 31663
  private FORGOTTEN_MONUMENT_4 = 31664
  private CORPSE_OF_DWARF = 31665
  # Items
  private KRORINS_JOURNAL = 7252
  # Misc
  private MIN_LVL = 66
  # Monuments
  private MONUMENTS = {
    FORGOTTEN_MONUMENT_1,
    FORGOTTEN_MONUMENT_2,
    FORGOTTEN_MONUMENT_3,
    FORGOTTEN_MONUMENT_4
  }

  def initialize
    super(31, self.class.simple_name, "Secret Buried in the Swamp")

    add_start_npc(ABERCROMBIE)
    add_talk_id(ABERCROMBIE, CORPSE_OF_DWARF)
    add_talk_id(MONUMENTS)
    register_quest_items(KRORINS_JOURNAL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "31555-02.html"
      if st.created?
        st.start_quest
        html = event
      end
    when "31665-02.html"
      if st.cond?(1)
        st.set_cond(2, true)
        st.give_items(KRORINS_JOURNAL, 1)
        html = event
      end
    when "31555-05.html"
      if st.cond?(2) && st.has_quest_items?(KRORINS_JOURNAL)
        st.take_items(KRORINS_JOURNAL, -1)
        st.set_cond(3, true)
        html = event
      end
    when "31661-02.html", "31662-02.html", "31663-02.html", "31664-02.html"
      idx = MONUMENTS.index(npc.not_nil!.id)
      if idx && st.cond?(idx + 3)
        st.set_cond(st.cond + 1, true)
        html = event
      end
    when "31555-08.html"
      if st.cond?(7)
        st.add_exp_and_sp(490000, 45880)
        st.give_adena(120000, true)
        st.exit_quest(false, true)
        html = event
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when ABERCROMBIE
      case st.state
      when State::CREATED
        html = pc.level >= MIN_LVL ? "31555-01.htm" : "31555-03.htm"
      when State::STARTED
        case st.cond
        when 1
          html = "31555-02.html"
        when 2
          if st.has_quest_items?(KRORINS_JOURNAL)
            html = "31555-04.html"
          end
        when 3
          html = "31555-06.html"
        when 7
          html = "31555-07.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end
    when CORPSE_OF_DWARF
      case st.cond
      when 1
        html = "31665-01.html"
      when 2
        html = "31665-03.html"
      end
    when FORGOTTEN_MONUMENT_1..FORGOTTEN_MONUMENT_4
      loc = MONUMENTS.index(npc.id).not_nil! + 3
      if st.cond?(loc)
        html = "#{npc.id}-01.html"
      elsif st.cond?(loc + 1)
        html = "#{npc.id}-03.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
