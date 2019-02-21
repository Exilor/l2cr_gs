class Quests::Q00042_HelpTheUncle < Quest
  # NPCs
  private WATERS = 30828
  private SOPHYA = 30735
  # Monsters
  private MONSTER_EYE_DESTROYER = 20068
  private MONSTER_EYE_GAZER = 20266
  # Items
  private TRIDENT = 291
  private MAP_PIECE = 7548
  private MAP = 7549
  private PET_TICKET = 7583

  def initialize
    super(42, self.class.simple_name, "Help The Uncle!")

    add_start_npc(WATERS)
    add_talk_id(WATERS, SOPHYA)
    add_kill_id(MONSTER_EYE_DESTROYER, MONSTER_EYE_GAZER)
    register_quest_items(MAP, MAP_PIECE)
  end

  def on_adv_event(event, npc, player)
    return unless player
    unless st = get_quest_state(player, false)
      return get_no_quest_msg(player)
    end

    htmltext = event
    case event
    when "30828-01.htm"
      st.start_quest
    when "30828-03.html"
      if st.has_quest_items?(TRIDENT)
        st.take_items(TRIDENT, 1)
        st.set_cond(2, true)
      else
        htmltext = "30828-03a.html"
      end
    when "30828-06.html"
      if st.get_quest_items_count(MAP_PIECE) == 30
        st.take_items(MAP_PIECE, -1)
        st.give_items(MAP, 1)
        st.set_cond(4, true)
      else
        htmltext = "30828-06a.html"
      end
    when "30735-02.html"
      if st.has_quest_items?(MAP)
        st.take_items(MAP, -1)
        st.set_cond(5, true)
      else
        htmltext = "30735-02a.html"
      end
    when "30828-09.html"
      st.give_items(PET_TICKET, 1)
      st.exit_quest(false, true)
    end

    htmltext
  end

  def on_kill(npc, player, is_summon)
    st = get_quest_state(player, false)

    if st && st.cond?(2)
      st.give_items(MAP_PIECE, 1)
      if st.get_quest_items_count(MAP_PIECE) == 30
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
    when WATERS
      case st.state
      when State::CREATED
        htmltext = player.level >= 25 ? "30828-00.htm" : "30828-00a.html"
      when State::STARTED
        case st.cond
        when 1
          htmltext = st.has_quest_items?(TRIDENT) ? "30828-02.html" : "30828-02a.html"
        when 2
          htmltext = "30828-04.html"
        when 3
          htmltext = "30828-05.html"
        when 4
          htmltext = "30828-07.html"
        when 5
          htmltext = "30828-08.html"
        end
      when State::COMPLETED
        htmltext = get_already_completed_msg(player)
      end
    when SOPHYA
      if st.started?
        case st.cond
        when 4
          htmltext = "30735-01.html"
        when 5
          htmltext = "30735-03.html"
        end
      end
    end

    htmltext || get_no_quest_msg(player)
  end
end
