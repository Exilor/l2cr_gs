class Scripts::Q00166_MassOfDarkness < Quest
  # NPCs
  private UNDRIAS = 30130
  private IRIA = 30135
  private DORANKUS = 30139
  private TRUDY = 30143
  # Items
  private UNDRIAS_LETTER = 1088
  private CEREMONIAL_DAGGER = 1089
  private DREVIANT_WINE = 1090
  private GARMIELS_SCRIPTURE = 1091
  # Misc
  private MIN_LVL = 2

  private NPCS = {
    IRIA     => CEREMONIAL_DAGGER,
    DORANKUS => DREVIANT_WINE,
    TRUDY    => GARMIELS_SCRIPTURE
  }

  def initialize
    super(166, self.class.simple_name, "Mass of Darkness")

    add_start_npc(UNDRIAS)
    add_talk_id(UNDRIAS, IRIA, DORANKUS, TRUDY)
    register_quest_items(
      UNDRIAS_LETTER, CEREMONIAL_DAGGER, DREVIANT_WINE, GARMIELS_SCRIPTURE
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event == "30130-03.htm"
      st.start_quest
      st.give_items(UNDRIAS_LETTER, 1)
      event
    end
  end

  def on_talk(npc, pc)
    unless st = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when UNDRIAS
      case st.state
      when State::CREATED
        if pc.race.dark_elf?
          if pc.level >= MIN_LVL
            html = "30130-02.htm"
          else
            html = "30130-01.htm"
          end
        else
          html = "30130-00.htm"
        end
      when State::STARTED
        if st.cond?(2) && st.has_quest_items?(UNDRIAS_LETTER, CEREMONIAL_DAGGER, DREVIANT_WINE, GARMIELS_SCRIPTURE)
          msg = NpcString::DELIVERY_DUTY_COMPLETE_N_GO_FIND_THE_NEWBIE_GUIDE
          show_on_screen_msg(pc, msg, 2, 5000)
          st.add_exp_and_sp(5672, 466)
          st.give_adena(2966, true)
          st.exit_quest(false, true)
          html = "30130-05.html"
        else
          html = "30130-04.html"
        end
      when State::COMPLETED
        html = get_already_completed_msg(pc)
      end

    when IRIA, DORANKUS, TRUDY
      if st.started?
        npc_id = npc.id
        item_id = NPCS[npc_id]

        if st.cond?(1) && !st.has_quest_items?(item_id)
          st.give_items(item_id, 1)
          if st.has_quest_items?(CEREMONIAL_DAGGER, DREVIANT_WINE, GARMIELS_SCRIPTURE)
            st.set_cond(2, true)
          end
          html = "#{npc_id}-01.html"
        else
          html = "#{npc_id}-02.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
