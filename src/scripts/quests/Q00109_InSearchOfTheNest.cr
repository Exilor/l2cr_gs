class Quests::Q00109_InSearchOfTheNest < Quest
  # NPCs
  private PIERCE = 31553
  private SCOUTS_CORPSE = 32015
  private KAHMAN = 31554
  # Items
  private SCOUTS_NOTE = 14858

  def initialize
    super(109, self.class.simple_name, "In Search of the Nest")

    add_start_npc(PIERCE)
    add_talk_id(PIERCE, SCOUTS_CORPSE, KAHMAN)
    register_quest_items(SCOUTS_NOTE)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end

    case event
    when "31553-0.htm"
      st.start_quest
    when "32015-2.html"
      st.give_items(SCOUTS_NOTE, 1)
      st.set_cond(2, true)
    when "31553-3.html"
      st.take_items(SCOUTS_NOTE, -1)
      st.set_cond(3, true)
    when "31554-2.html"
      st.give_adena(161500, true)
      st.add_exp_and_sp(701500, 50000)
      st.exit_quest(false, true)
    end

    event
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case npc.id
    when PIERCE
      case st.state
      when State::CREATED
        htmltext = player.level < 81 ? "31553-0a.htm" : "31553-0b.htm"
      when State::STARTED
        case st.cond
        when 1
          htmltext = "31553-1.html"
        when 2
          htmltext = "31553-2.html"
        when 3
          htmltext = "31553-3a.html"
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    when SCOUTS_CORPSE
      if st.started?
        if st.cond?(1)
          htmltext = "32015-1.html"
        elsif st.cond?(2)
          htmltext = "32015-3.html"
        end
      end
    when KAHMAN
      if st.started? && st.cond?(3)
        htmltext = "31554-1.html"
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
