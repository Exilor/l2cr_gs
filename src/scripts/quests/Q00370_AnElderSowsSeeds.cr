class Scripts::Q00370_AnElderSowsSeeds < Quest
  # NPC
  private CASIAN = 30612
  # Items
  private SPELLBOOK_PAGE = 5916
  private CHAPTER_OF_FIRE = 5917
  private CHAPTER_OF_WATER = 5918
  private CHAPTER_OF_WIND = 5919
  private CHAPTER_OF_EARTH = 5920
  # Misc
  private MIN_LEVEL = 28
  # Mobs
  private MOBS1 = {
    20082 => 9, # ant_recruit
    20086 => 9, # ant_guard
    20090 => 22 # noble_ant_leader
  }
  private MOBS2 = {
    20084 => 0.101, # ant_patrol
    20089 => 0.100  # noble_ant
  }

  def initialize
    super(370, self.class.simple_name, "An Elder Sows Seeds")

    add_start_npc(CASIAN)
    add_talk_id(CASIAN)
    add_kill_id(MOBS1.keys)
    add_kill_id(MOBS2.keys)
  end

  def check_party_member(pc : L2PcInstance, npc)
    st = get_quest_state(pc, false)
    !!st && st.started?
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    case event
    when "30612-02.htm", "30612-03.htm", "30612-06.html", "30612-07.html",
         "30612-09.html"
      html = event
    when "30612-04.htm"
      st.start_quest
      html = event
    when "REWARD"
      if st.started?
        if exchange_chapters(pc, false)
          html = "30612-08.html"
        else
          html = "30612-11.html"
        end
      end
    when "30612-10.html"
      if st.started?
        exchange_chapters(pc, true)
        st.exit_quest(true, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, pc, is_summon)
    npc_id = npc.id
    if tmp = MOBS1[npc_id]?
      if Rnd.rand(100) < tmp
        if winner = get_random_party_member(pc, npc)
          give_item_randomly(winner, npc, SPELLBOOK_PAGE, 1, 0, 1.0, true)
        end
      end
    else
      if st = get_random_party_member_state(pc, -1, 3, npc)
        give_item_randomly(st.player, npc, SPELLBOOK_PAGE, 1, 0, MOBS2[npc_id], true)
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)

    if st.created?
      html = pc.level >= MIN_LEVEL ? "30612-01.htm" : "30612-05.html"
    elsif st.started?
      html = "30612-06.html"
    end

    html || get_no_quest_msg(pc)
  end

  private def exchange_chapters(pc, take_all_items)
    water_chapters = get_quest_items_count(pc, CHAPTER_OF_WATER)
    earth_chapters = get_quest_items_count(pc, CHAPTER_OF_EARTH)
    wind_chapters = get_quest_items_count(pc, CHAPTER_OF_WIND)
    fire_chapters = get_quest_items_count(pc, CHAPTER_OF_FIRE)
    min_count = Util.min(water_chapters, earth_chapters, wind_chapters, fire_chapters)
    if min_count > 0
      give_adena(pc, min_count * 3600, true)
    end
    count_to_take = take_all_items ? -1 : min_count
    take_items(pc, count_to_take, {CHAPTER_OF_WATER, CHAPTER_OF_EARTH, CHAPTER_OF_WIND, CHAPTER_OF_FIRE})

    min_count > 0
  end
end
