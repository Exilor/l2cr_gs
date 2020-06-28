class Scripts::Q00906_TheCallOfValakas < Quest
  # NPC
  private KLEIN = 31540
  # Monster
  private LAVASAURUS_ALPHA = 29029
  # Items
  private LAVASAURUS_ALPHA_FRAGMENT = 21993
  private SCROLL_VALAKAS_CALL = 21895
  private VACUALITE_FLOATING_STONE = 7267
  # Misc
  private MIN_LEVEL = 83

  def initialize
    super(906, self.class.simple_name, "The Call of Valakas")

    add_start_npc(KLEIN)
    add_talk_id(KLEIN)
    add_kill_id(LAVASAURUS_ALPHA)
    register_quest_items(LAVASAURUS_ALPHA_FRAGMENT)
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && Util.in_range?(1500, npc, pc, false)
      st.give_items(LAVASAURUS_ALPHA_FRAGMENT, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      st.set_cond(2, true)
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if pc.level >= MIN_LEVEL && st.has_quest_items?(VACUALITE_FLOATING_STONE)
      case event
      when "31540-05.htm"
        html = event
      when "31540-06.html"
        st.start_quest
        html = event
      end

    end

    html
  end

  def on_kill(npc, killer, is_summon)
    execute_for_each_player(killer, npc, is_summon, true, false)
    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level < MIN_LEVEL
        html = "31540-03.html"
      elsif !st.has_quest_items?(VACUALITE_FLOATING_STONE)
        html = "31540-04.html"
      else
        html = "31540-01.htm"
      end
    when State::STARTED
      case st.cond
      when 1
        html = "31540-07.html"
      when 2
        st.give_items(SCROLL_VALAKAS_CALL, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        st.exit_quest(QuestType::DAILY, true)
        html = "31540-08.html"
      end

    when State::COMPLETED
      if !st.now_available?
        html = "31540-02.html"
      else
        st.state = State::CREATED
        if pc.level < MIN_LEVEL
          html = "31540-03.html"
        elsif !st.has_quest_items?(VACUALITE_FLOATING_STONE)
          html = "31540-04.html"
        else
          html = "31540-01.htm"
        end
      end
    end


    html || get_no_quest_msg(pc)
  end
end
