class Scripts::Q00612_BattleAgainstKetraOrcs < Quest
  # NPC
  private ASHAS = 31377
  # Monsters
  private MOBS = {
    21324 => 500, # Ketra Orc Footman
    21327 => 510, # Ketra Orc Raider
    21328 => 522, # Ketra Orc Scout
    21329 => 519, # Ketra Orc Shaman
    21331 => 529, # Ketra Orc Warrior
    21332 => 529, # Ketra Orc Lieutenant
    21334 => 539, # Ketra Orc Medium
    21336 => 548, # Ketra Orc White Captain
    21338 => 558, # Ketra Orc Seer
    21339 => 568, # Ketra Orc General
    21340 => 568, # Ketra Orc Battalion Commander
    21342 => 578, # Ketra Orc Grand Seer
    21343 => 664, # Ketra Commander
    21345 => 713, # Ketra's Head Shaman
    21347 => 738  # Ketra Prophet
  }
  # Items
  private SEED = 7187
  private MOLAR = 7234
  # Misc
  private MIN_LEVEL = 74
  private MOLAR_COUNT = 100

  def initialize
    super(612, self.class.simple_name, "Battle against Ketra Orcs")

    add_start_npc(ASHAS)
    add_talk_id(ASHAS)
    add_kill_id(MOBS.keys)
    register_quest_items(MOLAR)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "31377-03.htm"
      st.start_quest
    when "31377-06.html"
      # do nothing
    when "31377-07.html"
      if st.get_quest_items_count(MOLAR) < MOLAR_COUNT
        return "31377-08.html"
      end
      st.take_items(MOLAR, MOLAR_COUNT)
      st.give_items(SEED, 20)
    when "31377-09.html"
      st.exit_quest(true, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    member = get_random_party_member(killer, 1)
    if member && rand(1000) < MOBS[npc.id]
      st = get_quest_state!(member, false)
      st.give_items(MOLAR, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "31377-01.htm" : "31377-02.htm"
    when State::STARTED
      html = st.has_quest_items?(MOLAR) ? "31377-04.html" : "31377-05.html"
    end

    html || get_no_quest_msg(pc)
  end
end
