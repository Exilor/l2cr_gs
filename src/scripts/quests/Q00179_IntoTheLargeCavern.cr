class Quests::Q00179_IntoTheLargeCavern < Quest
  # NPCs
  private KEKROPUS = 32138
  private MENACING_MACHINE = 32258
  # Misc
  private MIN_LEVEL = 17
  private MAX_LEVEL = 21

  def initialize
    super(179, self.class.simple_name, "Into The Large Cavern")

    add_start_npc(KEKROPUS)
    add_talk_id(KEKROPUS, MENACING_MACHINE)
  end

  def on_adv_event(event, npc, player)
    return unless player && npc
    htmltext = event
    return htmltext unless st = get_quest_state(player, false)

    if npc.id == KEKROPUS
      if event.casecmp?("32138-03.html")
        st.start_quest
      end
    elsif npc.id == MENACING_MACHINE
      if event.casecmp?("32258-08.html")
        st.give_items(391, 1)
        st.give_items(413, 1)
        st.exit_quest(false, true)
      elsif event.casecmp?("32258-09.html")
        st.give_items(847, 2)
        st.give_items(890, 2)
        st.give_items(910, 1)
        st.exit_quest(false, true)
      end
    end

    htmltext
  end

  def on_talk(npc, player)
    htmltext = get_no_quest_msg(player)
    return htmltext unless st = get_quest_state(player, true)

    if npc.id == KEKROPUS
      case st.state
      when State::CREATED
        if !player.race.kamael?
          htmltext = "32138-00b.html"
        else
          prev = player.quest_completed?(Q00178_IconicTrinity.simple_name)
          level = player.level
          if prev && level >= MIN_LEVEL && level <= MAX_LEVEL && player.class_id.level == 0
            htmltext = "32138-01.htm"
          elsif level < MIN_LEVEL
            htmltext = "32138-00.html"
          else
            htmltext = "32138-00c.html"
          end
        end
      when State::STARTED
        if st.cond?(1)
          htmltext = "32138-03.htm"
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    elsif npc.id == MENACING_MACHINE && st.state == State::STARTED
      htmltext = "32258-01.html"
    end

    htmltext
  end
end
