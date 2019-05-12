class Scripts::Q10273_GoodDayToFly < Quest
  # NPC
  private LEKON = 32557
  # Monsters
  private MOBS = {
    22614, # Vulture Rider
    22615, # Vulture Rider
  }

  # Item
  private MARK = 13856
  # Skills
  private AURA_BIRD_FALCON = SkillHolder.new(5982, 1)
  private AURA_BIRD_OWL = SkillHolder.new(5983, 1)

  def initialize
    super(10273, self.class.simple_name, "Good Day to Fly")

    add_start_npc(LEKON)
    add_talk_id(LEKON)
    add_kill_id(MOBS)
    register_quest_items(MARK)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "32557-06.htm"
      st.start_quest
    when "32557-09.html"
      st.set("transform", "1")
      AURA_BIRD_FALCON.skill.apply_effects(pc, pc)
    when "32557-10.html"
      st.set("transform", "2")
      AURA_BIRD_OWL.skill.apply_effects(pc, pc)
    when "32557-13.html"
      case st.get_int("transform")
      when 1
        AURA_BIRD_FALCON.skill.apply_effects(pc, pc)
      when 2
        AURA_BIRD_OWL.skill.apply_effects(pc, pc)
      end
    end

    event
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st.nil? || !st.started?
      return
    end

    count = st.get_quest_items_count(MARK)
    if st.cond?(1) && count < 5
      st.give_items(MARK, 1)
      if count == 4
        st.set_cond(2, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    transform = st.get_int("transform")

    case st.state
    when State::COMPLETED
      html = "32557-0a.html"
    when State::CREATED
      html = pc.level < 75 ? "32557-00.html" : "32557-01.htm"
    else
      if st.get_quest_items_count(MARK) >= 5
        html = "32557-14.html"
        if transform == 1
          st.give_items(13553, 1)
        elsif transform == 2
          st.give_items(13554, 1)
        end
        st.give_items(13857, 1)
        st.add_exp_and_sp(25160, 2525)
        st.exit_quest(false, true)
      elsif transform == 0
        html = "32557-07.html"
      else
        html = "32557-11.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
