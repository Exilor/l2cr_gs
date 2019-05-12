class Scripts::Q00168_DeliverSupplies < Quest
  # NPCs
  private JENNA = 30349
  private ROSELYN = 30355
  private KRISTIN = 30357
  private HARANT = 30360
  # Items
  private JENNAS_LETTER = 1153
  private SENTRY_BLADE1 = 1154
  private SENTRY_BLADE2 = 1155
  private SENTRY_BLADE3 = 1156
  private OLD_BRONZE_SWORD = 1157
  # Misc
  private MIN_LVL = 3
  private SENTRIES = {
    KRISTIN => SENTRY_BLADE3,
    ROSELYN => SENTRY_BLADE2
  }

  def initialize
    super(168, self.class.simple_name, "Deliver Supplies")

    add_start_npc(JENNA)
    add_talk_id(JENNA, ROSELYN, KRISTIN, HARANT)
    register_quest_items(
      JENNAS_LETTER, SENTRY_BLADE1, SENTRY_BLADE2, SENTRY_BLADE3,
      OLD_BRONZE_SWORD
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    st = get_quest_state(pc, false)
    if st && event == "30349-03.htm"
      st.start_quest
      st.give_items(JENNAS_LETTER, 1)
      event
    end
  end

  def on_talk(npc, pc)
    if st = get_quest_state!(pc)
      case npc.id
      when JENNA
        case st.state
        when State::CREATED
          if pc.race.dark_elf?
            if pc.level >= MIN_LVL
              html = "30349-02.htm"
            else
              html = "30349-01.htm"
            end
          else
            html = "30349-00.htm"
          end
        when State::STARTED
          case st.cond
          when 1
            if st.has_quest_items?(JENNAS_LETTER)
              html = "30349-04.html"
            end
          when 2
            if st.has_quest_items?(SENTRY_BLADE1, SENTRY_BLADE2, SENTRY_BLADE3)
              st.take_items(SENTRY_BLADE1, -1)
              st.set_cond(3, true)
              html = "30349-05.html"
            end
          when 3
            if has_at_least_one_quest_item?(pc, SENTRY_BLADE2, SENTRY_BLADE3)
              html = "30349-07.html"
            end
          when 4
            if st.get_quest_items_count(OLD_BRONZE_SWORD) >= 2
              st.give_adena(820, true)
              st.exit_quest(false, true)
              html = "30349-07.html" # it looks like this needs a file ending in -08
            end
          end
        when State::COMPLETED
          html = get_already_completed_msg(pc)
        end
      when HARANT
        if st.cond?(1) && st.has_quest_items?(JENNAS_LETTER)
          st.take_items(JENNAS_LETTER, -1)
          st.give_items(SENTRY_BLADE1, 1)
          st.give_items(SENTRY_BLADE2, 1)
          st.give_items(SENTRY_BLADE3, 1)
          st.set_cond(2, true)
          html = "30360-01.html"
        elsif st.cond?(2)
          html = "30360-02.html"
        end
      when ROSELYN, KRISTIN
        if st.cond?(3) && st.has_quest_items?(SENTRIES[npc.id])
          st.take_items(SENTRIES[npc.id], -1)
          st.give_items(OLD_BRONZE_SWORD, 1)
          if st.get_quest_items_count(OLD_BRONZE_SWORD) >= 2
            st.set_cond(4, true)
          end
          html = "#{npc.id}-01.html"
        elsif !st.has_quest_items?(SENTRIES[npc.id]) && st.has_quest_items?(OLD_BRONZE_SWORD)
          html = "#{npc.id}-02.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
