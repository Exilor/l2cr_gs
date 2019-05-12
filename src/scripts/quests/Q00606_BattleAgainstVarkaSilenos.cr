class Scripts::Q00606_BattleAgainstVarkaSilenos < Quest
  # NPC
  private KADUN = 31370
  # Monsters
  private MOBS = {
    21350 => 500, # Varka Silenos Recruit
    21353 => 510, # Varka Silenos Scout
    21354 => 522, # Varka Silenos Hunter
    21355 => 519, # Varka Silenos Shaman
    21357 => 529, # Varka Silenos Priest
    21358 => 529, # Varka Silenos Warrior
    21360 => 539, # Varka Silenos Medium
    21362 => 539, # Varka Silenos Officer
    21364 => 558, # Varka Silenos Seer
    21365 => 568, # Varka Silenos Great Magus
    21366 => 568, # Varka Silenos General
    21368 => 568, # Varka Silenos Great Seer
    21369 => 664, # Varka's Commander
    21371 => 713, # Varka's Head Magus
    21373 => 738  # Varka's Prophet
  }
  # Items
  private HORN = 7186
  private MANE = 7233
  # Misc
  private MIN_LEVEL = 74
  private MANE_COUNT = 100

  def initialize
    super(606, self.class.simple_name, "Battle against Varka Silenos")

    add_start_npc(KADUN)
    add_talk_id(KADUN)
    add_kill_id(MOBS.keys)
    register_quest_items(MANE)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "31370-03.htm"
      st.start_quest
    when "31370-06.html"
      # do nothing
    when "31370-07.html"
      if st.get_quest_items_count(MANE) < MANE_COUNT
        return "31370-08.html"
      end
      st.take_items(MANE, MANE_COUNT)
      st.give_items(HORN, 20)
    when "31370-09.html"
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
      st.give_items(MANE, 1)
      st.play_sound(Sound::ITEMSOUND_QUEST_ITEMGET)
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "31370-01.htm" : "31370-02.htm"
    when State::STARTED
      html = st.has_quest_items?(MANE) ? "31370-04.html" : "31370-05.html"
    end

    html || get_no_quest_msg(pc)
  end
end
