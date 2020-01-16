class Scripts::Q00652_AnAgedExAdventurer < Quest
  # NPCs
  private TANTAN = 32012
  private SARA = 30180
  # Items
  private SOULSHOT_C = 1464
  private ENCHANT_ARMOR_D = 956

  def initialize
    super(652, self.class.simple_name, "An Aged Ex-Adventurer")

    add_start_npc(TANTAN)
    add_talk_id(TANTAN, SARA)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if event == "32012-04.htm"
      if st.get_quest_items_count(SOULSHOT_C) < 100
        return "32012-05.htm"
      end

      npc = npc.not_nil!

      st.start_quest
      st.take_items(SOULSHOT_C, 100)
      npc.delete_me
      html = event
    elsif event == "32012-03.html"
      html = event
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when TANTAN
      case st.state
      when State::CREATED
        html = pc.level >= 46 ? "32012-01.htm" : "32012-01a.htm"
      when State::STARTED
        html = "32012-02.html"
      end
    when SARA
      if st.started?
        if Rnd.rand(10) <= 4
          st.give_items(ENCHANT_ARMOR_D, 1)
          st.give_adena(5026, true)
          html = "30180-01.html"
        else
          st.give_adena(10000, true)
          html = "30180-02.html"
        end
        st.exit_quest(true, true)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
