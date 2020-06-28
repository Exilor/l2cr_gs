class Scripts::Q00137_TempleChampionPart1 < Quest
  # NPCs
  private SYLVAIN = 30070
  private MOBS = {
    20083, # Granite Golem
    20144, # Hangman Tree
    20199, # Amber Basilisk
    20200, # Strain
    20201, # Ghoul
    20202  # Dead Seeker
  }
  # Items
  private FRAGMENT = 10340
  private EXECUTOR = 10334
  private MISSIONARY = 10339

  def initialize
    super(137, self.class.simple_name, "Temple Champion - 1")

    add_start_npc(SYLVAIN)
    add_talk_id(SYLVAIN)
    add_kill_id(MOBS)
    register_quest_items(FRAGMENT)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "30070-02.htm"
      st.start_quest
    when "30070-05.html"
      st.set("talk", "1")
    when "30070-06.html"
      st.set("talk", "2")
    when "30070-08.html"
      st.unset("talk")
      st.set_cond(2, true)
    when "30070-16.html"
      if st.cond?(3) && st.has_quest_items?(EXECUTOR) && st.has_quest_items?(MISSIONARY)
        st.take_items(EXECUTOR, -1)
        st.take_items(MISSIONARY, -1)
        st.give_adena(69146, true)
        if pc.level < 41
          st.add_exp_and_sp(219975, 13047)
        end
        st.exit_quest(false, true)
      end
    end


    event
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.started? && st.cond?(2) && st.get_quest_items_count(FRAGMENT) < 30
      st.give_items(FRAGMENT, 1)
      if st.get_quest_items_count(FRAGMENT) >= 30
        st.set_cond(3, true)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    if st.completed?
      return get_already_completed_msg(pc)
    end

    case st.cond
    when 1
      case st.get_int("talk")
      when 1
        html = "30070-05.html"
      when 2
        html = "30070-06.html"
      else
        html = "30070-03.html"
      end
    when 2
      html = "30070-08.html"
    when 3
      if st.get_int("talk") == 1
        html = "30070-10.html"
      elsif st.get_quest_items_count(FRAGMENT) >= 30
        st.set("talk", "1")
        html = "30070-09.html"
        st.take_items(FRAGMENT, -1)
      end
    else
      if pc.level >= 35 && st.has_quest_items?(EXECUTOR, MISSIONARY)
        html = "30070-01.htm"
      else
        html = "30070-00.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
