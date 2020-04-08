class Scripts::Q00650_ABrokenDream < Quest
  # Npc
  private GHOST_OF_A_RAILROAD_ENGINEER = 32054
  # Item
  private REMNANTS_OF_OLD_DWARVES_DREAMS = 8514
  # Misc
  private MIN_LVL = 39
  # Monsters
  private MONSTER_DROP_CHANCES = {
    22027 => 575, # Forgotten Crewman
    22028 => 515  # Vagabond of the Ruins
  }

  def initialize
    super(650, self.class.simple_name, "A Broken Dream")

    add_start_npc(GHOST_OF_A_RAILROAD_ENGINEER)
    add_talk_id(GHOST_OF_A_RAILROAD_ENGINEER)
    add_kill_id(MONSTER_DROP_CHANCES.keys)
    register_quest_items(REMNANTS_OF_OLD_DWARVES_DREAMS)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "32054-03.htm"
      if st.created?
        st.start_quest
        html = event
      end
    when "32054-07.html", "32054-08.html"
      if st.started?
        html = event
      end
    when "32054-09.html"
      if st.started?
        st.exit_quest(true, true)
        html = event
      end
    else
      # automatically added
    end


    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level < MIN_LVL
        html = "32054-02.htm"
      else
        if pc.quest_completed?(Q00117_TheOceanOfDistantStars.simple_name)
          html = "32054-01.htm"
        else
          html = "32054-04.htm"
        end
      end
    when State::STARTED
      if st.has_quest_items?(REMNANTS_OF_OLD_DWARVES_DREAMS)
        html = "32054-05.html"
      else
        html = "32054-06.html"
      end
    else
      # automatically added
    end


    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    list = [] of L2PcInstance
    st = get_quest_state(killer, false)
    if st && st.started?
      list.push(killer, killer)
    end

    mob_chance = MONSTER_DROP_CHANCES[npc.id]
    if party = killer.party
      party.members.each do |m|
        qs = get_quest_state(m, false)
        if qs && qs.started?
          list << m
        end
      end
    end

    unless list.empty?
      pc = list.sample(random: Rnd)
      if Rnd.rand(1000) < mob_chance && Util.in_range?(1500, npc, pc, true)
        give_items(pc, REMNANTS_OF_OLD_DWARVES_DREAMS, 1)
        play_sound(pc, Sound::ITEMSOUND_QUEST_ITEMGET)
      end
    end

    super
  end
end