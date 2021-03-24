class Scripts::Q00649_ALooterAndARailroadMan < Quest
  # Npc
  private RAILMAN_OBI = 32052
  # Item
  private THIEF_GUILD_MARK = 8099
  # Misc
  private MIN_LVL = 30
  # Monsters
  private MONSTERS = {
    22017 => 529, # Bandit Sweeper
    22018 => 452, # Bandit Hound
    22019 => 606, # Bandit Watchman
    22021 => 615, # Bandit Undertaker
    22022 => 721, # Bandit Assassin
    22023 => 827, # Bandit Warrior
    22024 => 779, # Bandit Inspector
    22026 => 1000 # Bandit Captain
  }

  def initialize
    super(649, self.class.simple_name, "A Looter and a Railroad Man")

    add_start_npc(RAILMAN_OBI)
    add_talk_id(RAILMAN_OBI)
    add_kill_id(MONSTERS.keys)
    register_quest_items(THIEF_GUILD_MARK)
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (st = get_quest_state(pc, false))

    case event
    when "32052-03.htm"
      if st.created?
        st.start_quest
        html = event
      end
    when "32052-06.html"
      if st.cond?(2) && st.has_quest_items?(THIEF_GUILD_MARK)
        st.give_adena(21_698, true)
        st.exit_quest(true, true)
        html = event
      end
    end

    html
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      html = pc.level >= MIN_LVL ? "32052-01.htm" : "32052-02.htm"
    when State::STARTED
      count = st.get_quest_items_count(THIEF_GUILD_MARK)
      html = count == 200 ? "32052-04.html" : "32052-05.html"
    end

    html || get_no_quest_msg(pc)
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && st.cond?(1) && Util.in_range?(1500, npc, killer, false)
      if Rnd.rand(1000) < MONSTERS[npc.id]
        st.give_items(THIEF_GUILD_MARK, 1)
        if st.get_quest_items_count(THIEF_GUILD_MARK) == 200
          st.set_cond(2, true)
        else
          st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
        end
      end
    end

    super
  end
end
