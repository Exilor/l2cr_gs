class Scripts::Q10282_ToTheSeedOfAnnihilation < Quest
  # NPCs
  private KBALDIR = 32733
  private KLEMIS = 32734
  # Item
  private SOA_ORDERS = 15512

  def initialize
    super(10282, self.class.simple_name, "To the Seed of Annihilation")

    add_start_npc(KBALDIR)
    add_talk_id(KBALDIR, KLEMIS)
    register_quest_items(SOA_ORDERS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    html = event
    unless st = get_quest_state(pc, false)
      return html
    end

    case event
    when "32733-07.htm"
      st.start_quest
      st.give_items(SOA_ORDERS, 1)
    when "32734-02.htm"
      st.add_exp_and_sp(1_148_480, 99_110)
      st.exit_quest(false)
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    npc_id = npc.id
    case st.state
    when State::COMPLETED
      if npc_id == KBALDIR
        html = "32733-09.htm"
      elsif npc_id == KLEMIS
        html = "32734-03.htm"
      end
    when State::CREATED
      html = pc.level < 84 ? "32733-00.htm" : "32733-01.htm"
    when State::STARTED
      if st.cond?(1)
        if npc_id == KBALDIR
          html = "32733-08.htm"
        elsif npc_id == KLEMIS
          html = "32734-01.htm"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
