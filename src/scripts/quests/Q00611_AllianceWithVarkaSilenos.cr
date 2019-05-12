class Scripts::Q00611_AllianceWithVarkaSilenos < Quest
  private struct DropInfo
    getter chance, min_cond, item_id

    def initialize(chance : Int32, min_cond : Int32)
      @chance = chance
      @min_cond = min_cond
      case min_cond
      when 1
        @item_id = KETRA_BADGE_SOLDIER
      when 2
        @item_id = KETRA_BADGE_OFFICER
      else
        @item_id = KETRA_BADGE_CAPTAIN
      end
    end
  end

  # NPC
  private NARAN_ASHANUK = 31378
  # Monsters
  private MOBS = {
    21324 => DropInfo.new(500, 1), # Ketra Orc Footman
    21325 => DropInfo.new(500, 1), # Ketra's War Hound
    21327 => DropInfo.new(509, 1), # Ketra Orc Raider
    21328 => DropInfo.new(521, 1), # Ketra Orc Scout
    21329 => DropInfo.new(519, 1), # Ketra Orc Shaman
    21331 => DropInfo.new(500, 2), # Ketra Orc Warrior
    21332 => DropInfo.new(500, 2), # Ketra Orc Lieutenant
    21334 => DropInfo.new(509, 2), # Ketra Orc Medium
    21335 => DropInfo.new(518, 2), # Ketra Orc Elite Soldier
    21336 => DropInfo.new(518, 2), # Ketra Orc White Captain
    21338 => DropInfo.new(527, 2), # Ketra Orc Seer
    21339 => DropInfo.new(500, 3), # Ketra Orc General
    21340 => DropInfo.new(500, 3), # Ketra Orc Battalion Commander
    21342 => DropInfo.new(508, 3), # Ketra Orc Grand Seer
    21343 => DropInfo.new(628, 2), # Ketra Commander
    21344 => DropInfo.new(604, 2), # Ketra Elite Guard
    21345 => DropInfo.new(627, 3), # Ketra's Head Shaman
    21346 => DropInfo.new(604, 3), # Ketra's Head Guard
    21347 => DropInfo.new(649, 3), # Ketra Prophet
    21348 => DropInfo.new(626, 3), # Prophet's Guard
    21349 => DropInfo.new(626, 3)  # Prophet's Aide
  }
  # Items
  private KETRA_BADGE_SOLDIER = 7226
  private KETRA_BADGE_OFFICER = 7227
  private KETRA_BADGE_CAPTAIN = 7228
  private VALOR_FEATHER = 7229
  private WISDOM_FEATHER = 7230
  private KETRA_MARKS = {
    7211, # Mark of Ketra's Alliance - Level 1
    7212, # Mark of Ketra's Alliance - Level 2
    7213, # Mark of Ketra's Alliance - Level 3
    7214, # Mark of Ketra's Alliance - Level 4
    7215  # Mark of Ketra's Alliance - Level 5
  }
  private VARKA_MARKS = {
    7221, # Mark of Varka's Alliance - Level 1
    7222, # Mark of Varka's Alliance - Level 2
    7223, # Mark of Varka's Alliance - Level 3
    7224, # Mark of Varka's Alliance - Level 4
    7225  # Mark of Varka's Alliance - Level 5
  }
  # Misc
  private MIN_LEVEL = 74
  private SOLDIER_BADGE_COUNT = {
    100, # cond 1
    200, # cond 2
    300, # cond 3
    300, # cond 4
    400  # cond 5
  }
  private OFFICER_BADGE_COUNT = {
    0, # cond 1
    100, # cond 2
    200, # cond 3
    300, # cond 4
    400  # cond 5
  }
  private CAPTAIN_BADGE_COUNT = {
    0, # cond 1
    0, # cond 2
    100, # cond 3
    200, # cond 4
    200  # cond 5
  }

  def initialize
    super(611, self.class.simple_name, "Alliance with Varka Silenos")

    add_start_npc(NARAN_ASHANUK)
    add_talk_id(NARAN_ASHANUK)
    add_kill_id(MOBS.keys)
    register_quest_items(
      KETRA_BADGE_CAPTAIN, KETRA_BADGE_OFFICER, KETRA_BADGE_SOLDIER
    )
  end

  private def can_get_item?(st : QuestState, item_id : Int32)
    count = 0
    case item_id
    when KETRA_BADGE_SOLDIER
      count = SOLDIER_BADGE_COUNT[st.cond - 1]
    when KETRA_BADGE_OFFICER
      count = OFFICER_BADGE_COUNT[st.cond - 1]
    when KETRA_BADGE_CAPTAIN
      count = CAPTAIN_BADGE_COUNT[st.cond - 1]
    end

    st.get_quest_items_count(item_id) < count
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "31378-12a.html", "31378-12b.html", "31378-25.html"
      # do nothing
    when "31378-04.htm"
      if has_at_least_one_quest_item?(pc, KETRA_MARKS)
        return "31378-03.htm"
      end
      st.state = State::STARTED
      st.play_sound(Sound::ITEMSOUND_QUEST_ACCEPT)
      VARKA_MARKS.each_with_index do |mark, i|
        if st.has_quest_items?(mark)
          st.set_cond(i + 2)
          return "31378-0#{i + 5}.htm"
        end
      end
      st.set_cond(1)
    when "31378-12.html"
      if st.get_quest_items_count(KETRA_BADGE_SOLDIER) < SOLDIER_BADGE_COUNT[0]
        return get_no_quest_msg(pc)
      end
      st.take_items(KETRA_BADGE_SOLDIER, -1)
      st.give_items(VARKA_MARKS[0], 1)
      st.set_cond(2, true)
    when "31378-15.html"
      if st.get_quest_items_count(KETRA_BADGE_SOLDIER) < SOLDIER_BADGE_COUNT[1] || st.get_quest_items_count(KETRA_BADGE_OFFICER) < OFFICER_BADGE_COUNT[1]
        return get_no_quest_msg(pc)
      end
      take_items(pc, -1, {KETRA_BADGE_SOLDIER, KETRA_BADGE_OFFICER, VARKA_MARKS[0]})
      st.give_items(VARKA_MARKS[1], 1)
      st.set_cond(3, true)
    when "31378-18.html"
      if st.get_quest_items_count(KETRA_BADGE_SOLDIER) < SOLDIER_BADGE_COUNT[2] || st.get_quest_items_count(KETRA_BADGE_OFFICER) < OFFICER_BADGE_COUNT[2] || st.get_quest_items_count(KETRA_BADGE_CAPTAIN) < CAPTAIN_BADGE_COUNT[2]
        return get_no_quest_msg(pc)
      end
      take_items(pc, -1, {KETRA_BADGE_SOLDIER, KETRA_BADGE_OFFICER, KETRA_BADGE_CAPTAIN, VARKA_MARKS[1]})
      st.give_items(VARKA_MARKS[2], 1)
      st.set_cond(4, true)
    when "31378-21.html"
      if !st.has_quest_items?(VALOR_FEATHER) || st.get_quest_items_count(KETRA_BADGE_SOLDIER) < SOLDIER_BADGE_COUNT[3] || st.get_quest_items_count(KETRA_BADGE_OFFICER) < OFFICER_BADGE_COUNT[3] || st.get_quest_items_count(KETRA_BADGE_CAPTAIN) < CAPTAIN_BADGE_COUNT[3]
        return get_no_quest_msg(pc)
      end
      take_items(pc, -1, {KETRA_BADGE_SOLDIER, KETRA_BADGE_OFFICER, KETRA_BADGE_CAPTAIN, VALOR_FEATHER, VARKA_MARKS[2]})
      st.give_items(VARKA_MARKS[3], 1)
      st.set_cond(5, true)
    when "31378-26.html"
      take_items(pc, -1, VARKA_MARKS)
      take_items(pc, -1, {VALOR_FEATHER, WISDOM_FEATHER})
      st.exit_quest(true, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    if member = get_random_party_member_state(killer, State::STARTED)
      st = get_quest_state!(member, false)
      info = MOBS[npc.id]
      if st.cond >= info.min_cond && st.cond < 6
        if can_get_item?(st, info.item_id) && rand(1000) < info.chance
          st.give_items(info.item_id, 1)
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    st = get_quest_state!(pc)
    case st.state
    when State::CREATED
      html = pc.level >= MIN_LEVEL ? "31378-01.htm" : "31378-02.htm"
    when State::STARTED
      case st.cond
      when 1
        if st.get_quest_items_count(KETRA_BADGE_SOLDIER) >= SOLDIER_BADGE_COUNT[0]
          html = "31378-11.html"
        else
          html = "31378-10.html"
        end
      when 2
        if st.has_quest_items?(VARKA_MARKS[0]) && st.get_quest_items_count(KETRA_BADGE_SOLDIER) >= SOLDIER_BADGE_COUNT[1] && st.get_quest_items_count(KETRA_BADGE_OFFICER) >= OFFICER_BADGE_COUNT[1]
          html = "31378-14.html"
        else
          html = "31378-13.html"
        end
      when 3
        if st.has_quest_items?(VARKA_MARKS[1]) && st.get_quest_items_count(KETRA_BADGE_SOLDIER) >= SOLDIER_BADGE_COUNT[2] && st.get_quest_items_count(KETRA_BADGE_OFFICER) >= OFFICER_BADGE_COUNT[2] && st.get_quest_items_count(KETRA_BADGE_CAPTAIN) >= CAPTAIN_BADGE_COUNT[2]
          html = "31378-17.html"
        else
          html = "31378-16.html"
        end
      when 4
        if has_quest_items?(pc, VARKA_MARKS[2], VALOR_FEATHER) && st.get_quest_items_count(KETRA_BADGE_SOLDIER) >= SOLDIER_BADGE_COUNT[3] && st.get_quest_items_count(KETRA_BADGE_OFFICER) >= OFFICER_BADGE_COUNT[3] && st.get_quest_items_count(KETRA_BADGE_CAPTAIN) >= CAPTAIN_BADGE_COUNT[3]
          html = "31378-20.html"
        else
          html = "31378-19.html"
        end
      when 5
        if !st.has_quest_items?(VARKA_MARKS[3]) || !st.has_quest_items?(WISDOM_FEATHER) || st.get_quest_items_count(KETRA_BADGE_SOLDIER) < SOLDIER_BADGE_COUNT[4] || st.get_quest_items_count(KETRA_BADGE_OFFICER) < OFFICER_BADGE_COUNT[4] || st.get_quest_items_count(KETRA_BADGE_CAPTAIN) < CAPTAIN_BADGE_COUNT[4]
          return "31378-22.html"
        end
        st.set_cond(6, true)
        take_items(pc, -1, {KETRA_BADGE_SOLDIER, KETRA_BADGE_OFFICER, KETRA_BADGE_CAPTAIN, WISDOM_FEATHER, VARKA_MARKS[3]})
        st.give_items(VARKA_MARKS[4], 1)
        html = "31378-23.html"
      when 6
        if st.has_quest_items?(VARKA_MARKS[4])
          html = "31378-24.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
