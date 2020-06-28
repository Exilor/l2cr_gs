class Scripts::Q10274_CollectingInTheAir < Quest
  # NPC
  private LEKON = 32557
  # Items
  private SCROLL = 13844
  private RED = 13858
  private BLUE = 13859
  private GREEN = 13860
  # Monsters
  private MOBS = {
    18684, # Red Star Stone
    18685, # Red Star Stone
    18686, # Red Star Stone
    18687, # Blue Star Stone
    18688, # Blue Star Stone
    18689, # Blue Star Stone
    18690, # Green Star Stone
    18691, # Green Star Stone
    18692, # Green Star Stone
  }

  def initialize
    super(10274, self.class.simple_name, "Collecting in the Air")

    add_start_npc(LEKON)
    add_talk_id(LEKON)
    add_skill_see_id(MOBS)
    register_quest_items(SCROLL, RED, BLUE, GREEN)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    if event == "32557-03.html"
      st.start_quest
      st.give_items(SCROLL, 8)
    end

    event
  end

  def on_skill_see(npc, caster, skill, targets, is_summon)
    st = get_quest_state(caster, false)
    if st.nil? || !st.started?
      return
    end

    if st.cond?(1) && skill.id == 2630
      case npc.id
      when 18684..18686
        st.give_items(RED, 1)
      when 18687..18689
        st.give_items(BLUE, 1)
      when 18690..18692
        st.give_items(GREEN, 1)
      end

      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      npc.do_die(caster)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::COMPLETED
      html = "32557-0a.html"
    when State::CREATED
      if pc.level >= 75 && pc.quest_completed?(Q10273_GoodDayToFly.simple_name)
        html = "32557-01.htm"
      else
        html = "32557-00.html"
      end
    when State::STARTED
      count = st.get_quest_items_count(RED) + st.get_quest_items_count(BLUE)
      count &+= st.get_quest_items_count(GREEN)
      if count >= 8
        html = "32557-05.html"
        st.give_items(13728, 1)
        st.add_exp_and_sp(25160, 2525)
        st.exit_quest(false, true)
      else
        html = "32557-04.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
