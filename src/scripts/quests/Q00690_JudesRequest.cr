class Scripts::Q00690_JudesRequest < Quest
  # NPCs
  private JUDE = 32356
  private LESSER_EVIL = 22398
  private GREATER_EVIL = 22399
  # Items
  private EVIL_WEAPON = 10327
  private REWARDS = {
    {
      10373,
      10374,
      10375,
      10376,
      10377,
      10378,
      10379,
      10380,
      10381
    },
    {
      10397,
      10398,
      10399,
      10400,
      10401,
      10402,
      10403,
      10404,
      10405
    }
  }

  def initialize
    super(690, self.class.simple_name, "Jude's Request")

    add_start_npc(JUDE)
    add_talk_id(JUDE)
    add_kill_id(LESSER_EVIL, GREATER_EVIL)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return get_no_quest_msg(pc)
    end

    if event.casecmp?("32356-03.htm")
      st.start_quest
    elsif event.casecmp?("32356-07.htm")
      if st.get_quest_items_count(EVIL_WEAPON) >= 200
        st.give_items(REWARDS[0].sample(random: Rnd), 1)
        st.take_items(EVIL_WEAPON, 200)
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        html = "32356-07.htm"
      else
        html = "32356-07a.htm"
      end
    elsif event.casecmp?("32356-08.htm")
      st.take_items(EVIL_WEAPON, -1)
      st.exit_quest(true, true)
    elsif event.casecmp?("32356-09.htm")
      if st.get_quest_items_count(EVIL_WEAPON) >= 5
        st.give_items(REWARDS[1].sample(random: Rnd), 1)
        st.take_items(EVIL_WEAPON, 5)
        st.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        html = "32356-09.htm"
      else
        html = "32356-09a.htm"
      end
    end

    html || event
  end

  def on_kill(npc, pc, is_summon)
    unless member = get_random_party_member(pc, 1)
      return
    end
    st = get_quest_state!(member, false)

    npc_id = npc.id
    chance = 0
    if npc_id == LESSER_EVIL
      chance = 173
    elsif npc_id == GREATER_EVIL
      chance = 246
    end
    chance *= Config.rate_quest_drop
    chance %= 1000

    if Rnd.rand(1000) <= chance
      st.give_items(EVIL_WEAPON, Math.max((chance / 1000).to_i, 1))
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    nil
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    case st.state
    when State::CREATED
      if pc.level >= 78
        html = "32356-01.htm"
      else
        html = "32356-02.htm"
      end
    when State::STARTED
      if st.get_quest_items_count(EVIL_WEAPON) >= 200
        html = "32356-04.htm"
      elsif st.get_quest_items_count(EVIL_WEAPON) < 5
        html = "32356-05a.htm"
      else
        html = "32356-05.htm"
      end
    end

    html || get_no_quest_msg(pc)
  end
end
