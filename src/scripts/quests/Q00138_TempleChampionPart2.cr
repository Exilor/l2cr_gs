class Scripts::Q00138_TempleChampionPart2 < Quest
  # NPCs
  private SYLVAIN = 30070
  private PUPINA = 30118
  private ANGUS = 30474
  private SLA = 30666
  private MOBS = {
    20176, # Wyrm
    20550, # Guardian Basilisk
    20551, # Road Scavenger
    20552  # Fettered Soul
  }
  # Items
  private TEMPLE_MANIFESTO = 10341
  private RELICS_OF_THE_DARK_ELF_TRAINEE = 10342
  private ANGUS_RECOMMENDATION = 10343
  private PUPINAS_RECOMMENDATION = 10344

  def initialize
    super(138, self.class.simple_name, "Temple Champion - 2")

    add_start_npc(SYLVAIN)
    add_talk_id(SYLVAIN, PUPINA, ANGUS, SLA)
    add_kill_id(MOBS)
    register_quest_items(TEMPLE_MANIFESTO, RELICS_OF_THE_DARK_ELF_TRAINEE, ANGUS_RECOMMENDATION, PUPINAS_RECOMMENDATION)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    case event
    when "30070-02.htm"
      st.start_quest
      st.give_items(TEMPLE_MANIFESTO, 1)
    when "30070-05.html"
      st.give_adena(84593, true)
      if pc.level < 42
        st.add_exp_and_sp(187062, 11307)
      end
      st.exit_quest(false, true)
    when "30070-03.html"
      st.set_cond(2, true)
    when "30118-06.html"
      st.set_cond(3, true)
    when "30118-09.html"
      st.set_cond(6, true)
      st.give_items(PUPINAS_RECOMMENDATION, 1)
    when "30474-02.html"
      st.set_cond(4, true)
    when "30666-02.html"
      if st.has_quest_items?(PUPINAS_RECOMMENDATION)
        st.set("talk", "1")
        st.take_items(PUPINAS_RECOMMENDATION, -1)
      end
    when "30666-03.html"
      if st.has_quest_items?(TEMPLE_MANIFESTO)
        st.set("talk", "2")
        st.take_items(TEMPLE_MANIFESTO, -1)
      end
    when "30666-08.html"
      st.set_cond(7, true)
      st.unset("talk")
    end

    event
  end

  def on_kill(npc, pc, is_summon)
    st = get_quest_state(pc, false)
    if st && st.started? && st.cond?(4) && st.get_quest_items_count(RELICS_OF_THE_DARK_ELF_TRAINEE) < 10
      st.give_items(RELICS_OF_THE_DARK_ELF_TRAINEE, 1)
      if st.get_quest_items_count(RELICS_OF_THE_DARK_ELF_TRAINEE) >= 10
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
      else
        st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case npc.id
    when SYLVAIN
      case st.cond
      when 1
        html = "30070-02.htm"
      when 2..6
        html = "30070-03.html"
      when 7
        html = "30070-04.html"
      else
        if st.completed?
          return get_already_completed_msg(pc)
        end
        if pc.level >= 36
          if pc.quest_completed?(Q00137_TempleChampionPart1.simple_name)
            html = "30070-01.htm"
          else
            html = "30070-00a.htm"
          end
        else
          html = "30070-00.htm"
        end
      end
    when PUPINA
      case st.cond
      when 2
        html = "30118-01.html"
      when 3, 4
        html = "30118-07.html"
      when 5
        html = "30118-08.html"
        if st.has_quest_items?(ANGUS_RECOMMENDATION)
          st.take_items(ANGUS_RECOMMENDATION, -1)
        end
      when 6
        html = "30118-10.html"
      end
    when ANGUS
      case st.cond
      when 3
        html = "30474-01.html"
      when 4
        if st.get_quest_items_count(RELICS_OF_THE_DARK_ELF_TRAINEE) >= 10
          st.take_items(RELICS_OF_THE_DARK_ELF_TRAINEE, -1)
          st.give_items(ANGUS_RECOMMENDATION, 1)
          st.set_cond(5, true)
          html = "30474-04.html"
        else
          html = "30474-03.html"
        end
      when 5
        html = "30474-05.html"
      end
    when SLA
      case st.cond
      when 6
        case st.get_int("talk")
        when 1
          html = "30666-02.html"
        when 2
          html = "30666-03.html"
        else
          html = "30666-01.html"
        end
      when 7
        html = "30666-09.html"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
