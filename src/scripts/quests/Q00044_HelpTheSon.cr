class Quests::Q00044_HelpTheSon < Quest
  # NPCs
  private LUNDY = 30827
  private DRIKUS = 30505
  # Monsters
  private MAILLE_GUARD = 20921
  private MAILLE_SCOUT = 20920
  private MAILLE_LIZARDMAN = 20919
  # Items
  private WORK_HAMMER = 168
  private GEMSTONE_FRAGMENT = 7552
  private GEMSTONE = 7553
  private PET_TICKET = 7585

  def initialize
    super(44, self.class.simple_name, "Help The Son!")

    add_start_npc(LUNDY)
    add_talk_id(LUNDY, DRIKUS)
    add_kill_id(MAILLE_GUARD, MAILLE_LIZARDMAN, MAILLE_SCOUT)
    register_quest_items(GEMSTONE, GEMSTONE_FRAGMENT)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end

    htmltext = event
    case event
    when "30827-01.htm"
      st.start_quest
    when "30827-03.html"
      if st.has_quest_items?(WORK_HAMMER)
        st.take_items(WORK_HAMMER, 1)
        st.set_cond(2, true)
      else
        htmltext = "30827-03a.html"
      end
    when "30827-06.html"
      if st.get_quest_items_count(GEMSTONE_FRAGMENT) == 30
        st.take_items(GEMSTONE_FRAGMENT, -1)
        st.give_items(GEMSTONE, 1)
        st.set_cond(4, true)
      else
        htmltext = "30827-06a.html"
      end
    when "30505-02.html"
      if st.has_quest_items?(GEMSTONE)
        st.take_items(GEMSTONE, -1)
        st.set_cond(5, true)
      else
        htmltext = "30505-02a.html"
      end
    when "30827-09.html"
      st.give_items(PET_TICKET, 1)
      st.exit_quest(false, true)
    end

    htmltext
  end

  def on_kill(npc, player, is_summon)
    st = get_quest_state(player, false)
    if st && st.cond?(2)
      st.give_items(GEMSTONE_FRAGMENT, 1)
      if st.get_quest_items_count(GEMSTONE_FRAGMENT) == 30
        st.set_cond(3, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, player)
    st = get_quest_state!(player)

    case npc.id
    when LUNDY
      case st.state
      when State::CREATED
        htmltext = player.level >= 24 ? "30827-00.htm" : "30827-00a.html"
      when State::STARTED
        case st.cond
        when 1
          htmltext = st.has_quest_items?(WORK_HAMMER) ? "30827-02.html" : "30827-02a.html"
        when 2
          htmltext = "30827-04.html"
        when 3
          htmltext = "30827-05.html"
        when 4
          htmltext = "30827-07.html"
        when 5
          htmltext = "30827-08.html"
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    when DRIKUS
      if st.started?
        case st.cond
        when 4
          htmltext = "30505-01.html"
        when 5
          htmltext = "30505-03.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
