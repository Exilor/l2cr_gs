class Scripts::Q00552_OlympiadVeteran < Quest
  # NPC
  private MANAGER = 31688
  # Items
  private TEAM_EVENT_CERTIFICATE = 17241
  private CLASS_FREE_BATTLE_CERTIFICATE = 17242
  private CLASS_BATTLE_CERTIFICATE = 17243
  private OLY_CHEST = 17169

  def initialize
    super(552, self.class.simple_name, "Olympiad Veteran")

    add_start_npc(MANAGER)
    add_talk_id(MANAGER)
    register_quest_items(
      TEAM_EVENT_CERTIFICATE, CLASS_FREE_BATTLE_CERTIFICATE,
      CLASS_BATTLE_CERTIFICATE
    )
    add_olympiad_match_finish_id
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end
    html = event

    if event.casecmp?("31688-03.html")
      st.start_quest
    elsif event.casecmp?("31688-04.html")
      count = st.get_quest_items_count(TEAM_EVENT_CERTIFICATE)
      count += st.get_quest_items_count(CLASS_FREE_BATTLE_CERTIFICATE)
      count += st.get_quest_items_count(CLASS_BATTLE_CERTIFICATE)

      if count > 0
        st.give_items(OLY_CHEST, count)
        st.exit_quest(QuestType::DAILY, true)
      else
        html = get_no_quest_msg(pc)
      end
    end

    html
  end

  def on_olympiad_match_finish(winner, loser, type)
    if winner
      unless player = winner.player?
        return
      end

      st = get_quest_state(player, false)
      if st && st.started?
        case type
        when CompetitionType::CLASSED
          matches = st.get_int("classed") + 1
          st.set("classed", matches.to_s)
          if matches == 5 && !st.has_quest_items?(CLASS_BATTLE_CERTIFICATE)
            st.give_items(CLASS_BATTLE_CERTIFICATE, 1)
          end
        when CompetitionType::NON_CLASSED
          matches = st.get_int("nonclassed") + 1
          st.set("nonclassed", matches.to_s)
          if matches == 5 && !st.has_quest_items?(CLASS_FREE_BATTLE_CERTIFICATE)
            st.give_items(CLASS_FREE_BATTLE_CERTIFICATE, 1)
          end
        when CompetitionType::TEAMS
          matches = st.get_int("teams") + 1
          st.set("teams", matches.to_s)
          if matches == 5 && !st.has_quest_items?(TEAM_EVENT_CERTIFICATE)
            st.give_items(TEAM_EVENT_CERTIFICATE, 1)
          end
        else
          # [automatically added else]
        end

      end
    end

    if loser
      unless player = loser.player?
        return
      end
      st = get_quest_state(player, false)
      if st && st.started?
        case type
        when CompetitionType::CLASSED
          matches = st.get_int("classed") + 1
          st.set("classed", matches.to_s)
          if matches == 5
            st.give_items(CLASS_BATTLE_CERTIFICATE, 1)
          end
        when CompetitionType::NON_CLASSED
          matches = st.get_int("nonclassed") + 1
          st.set("nonclassed", matches.to_s)
          if matches == 5
            st.give_items(CLASS_FREE_BATTLE_CERTIFICATE, 1)
          end
        when CompetitionType::TEAMS
          matches = st.get_int("teams") + 1
          st.set("teams", matches.to_s)
          if matches == 5
            st.give_items(TEAM_EVENT_CERTIFICATE, 1)
          end
        else
          # [automatically added else]
        end

      end
    end
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if pc.level < 75 || !pc.noble?
      html = "31688-00.htm"
    elsif st.created?
      html = "31688-01.htm"
    elsif st.completed?
      if st.now_available?
        st.state = State::CREATED
        html = pc.level < 75 || !pc.noble? ? "31688-00.htm" : "31688-01.htm"
      else
        html = "31688-05.html"
      end
    elsif st.started?
      count = st.get_quest_items_count(TEAM_EVENT_CERTIFICATE)
      count += st.get_quest_items_count(CLASS_FREE_BATTLE_CERTIFICATE)
      count += st.get_quest_items_count(CLASS_BATTLE_CERTIFICATE)

      if count == 3
        html = "31688-04.html"
        st.give_items(OLY_CHEST, 4)
        st.exit_quest(QuestType::DAILY, true)
      else
        html = "31688-s#{count}.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
