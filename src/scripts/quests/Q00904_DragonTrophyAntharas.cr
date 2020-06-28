class Scripts::Q00904_DragonTrophyAntharas < Quest
  # NPC
  private THEODRIC = 30755
  # Monster
  private ANTHARAS = 29068
  # Items
  private MEDAL_OF_GLORY = 21874
  private PORTAL_STONE = 3865
  # Misc
  private MIN_LEVEL = 84

  def initialize
    super(904, self.class.simple_name, "Dragon Trophy - Antharas")

    add_start_npc(THEODRIC)
    add_talk_id(THEODRIC)
    add_kill_id(ANTHARAS)
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.cond?(1) && Util.in_range?(1500, npc, pc, false)
      st.set_cond(2, true)
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if pc.level >= MIN_LEVEL && st.has_quest_items?(PORTAL_STONE)
      case event
      when "30755-05.htm", "30755-06.htm"
        html = event
      when "30755-07.html"
        st.start_quest
        html = event
      end

    end

    html
  end

  def on_kill(npc, killer, is_summon)
    execute_for_each_player(killer, npc, is_summon, true, true)
    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level < MIN_LEVEL
        html = "30755-02.html"
      elsif !st.has_quest_items?(PORTAL_STONE)
        html = "30755-04.html"
      else
        html = "30755-01.htm"
      end
    when State::STARTED
      case st.cond
      when 1
        html = "30755-08.html"
      when 2
        st.give_items(MEDAL_OF_GLORY, 30)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        st.exit_quest(QuestType::DAILY, true)
        html = "30755-09.html"
      end

    when State::COMPLETED
      if !st.now_available?
        html = "30755-03.html"
      else
        st.state=(State::CREATED)
        if pc.level < MIN_LEVEL
          html = "30755-02.html"
        elsif !st.has_quest_items?(PORTAL_STONE)
          html = "30755-04.html"
        else
          html = "30755-01.htm"
        end
      end
    end



    html || get_no_quest_msg(pc)
  end
end
