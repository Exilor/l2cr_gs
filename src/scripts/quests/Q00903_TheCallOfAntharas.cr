class Scripts::Q00903_TheCallOfAntharas < Quest
  # NPC
  private THEODRIC = 30755
  # Monsters
  private BEHEMOTH_DRAGON = 29069
  private TARASK_DRAGON = 29190
  # Items
  private TARASK_DRAGONS_LEATHER_FRAGMENT = 21991
  private BEHEMOTH_DRAGON_LEATHER = 21992
  private SCROLL_ANTHARAS_CALL = 21897
  private PORTAL_STONE = 3865
  # Misc
  private MIN_LEVEL = 83

  def initialize
    super(903, self.class.simple_name, "The Call of Antharas")

    add_start_npc(THEODRIC)
    add_talk_id(THEODRIC)
    add_kill_id(BEHEMOTH_DRAGON, TARASK_DRAGON)
    register_quest_items(
      TARASK_DRAGONS_LEATHER_FRAGMENT, BEHEMOTH_DRAGON_LEATHER
    )
  end

  def action_for_each_player(pc, npc, is_summon)
    st = get_quest_state(pc, false)
    if st && Util.in_range?(1500, npc, pc, false)
      case npc.id
      when BEHEMOTH_DRAGON
        st.give_items(BEHEMOTH_DRAGON_LEATHER, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      when TARASK_DRAGON
        st.give_items(TARASK_DRAGONS_LEATHER_FRAGMENT, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end


      if st.has_quest_items?(BEHEMOTH_DRAGON_LEATHER)
        if st.has_quest_items?(TARASK_DRAGONS_LEATHER_FRAGMENT)
          st.set_cond(2, true)
        end
      end
    end
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    if pc.level >= MIN_LEVEL && st.has_quest_items?(PORTAL_STONE)
      case event
      when "30755-05.htm"
        html = event
      when "30755-06.html"
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
        html = "30755-03.html"
      elsif !st.has_quest_items?(PORTAL_STONE)
        html = "30755-04.html"
      else
        html = "30755-01.htm"
      end
    when State::STARTED
      case st.cond
      when 1
        html = "30755-07.html"
      when 2
        st.give_items(SCROLL_ANTHARAS_CALL, 1)
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        st.exit_quest(QuestType::DAILY, true)
        html = "30755-08.html"
      end

    when State::COMPLETED
      if !st.now_available?
        html = "30755-02.html"
      else
        st.state = State::CREATED
        if pc.level < MIN_LEVEL
          html = "30755-03.html"
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
