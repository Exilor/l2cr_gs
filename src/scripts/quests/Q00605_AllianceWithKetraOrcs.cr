class Scripts::Q00605_AllianceWithKetraOrcs < Quest
  private struct DropInfo
    getter chance, min_cond, item_id

    def initialize(chance : Int32, min_cond : Int32)
      @chance = chance
      @min_cond = min_cond
      case min_cond
      when 1
        @item_id = VARKA_BADGE_SOLDIER
      when 2
        @item_id = VARKA_BADGE_OFFICER
      else
        @item_id = VARKA_BADGE_CAPTAIN
      end
    end
  end

  # NPC
  private WAHKAN = 31371
  # Monsters
  private MOBS = {
    21350 => DropInfo.new(500, 1), # Varka Silenos Recruit
    21351 => DropInfo.new(500, 1), # Varka Silenos Footman
    21353 => DropInfo.new(509, 1), # Varka Silenos Scout
    21354 => DropInfo.new(521, 1), # Varka Silenos Hunter
    21355 => DropInfo.new(519, 1), # Varka Silenos Shaman
    21357 => DropInfo.new(500, 2), # Varka Silenos Priest
    21358 => DropInfo.new(500, 2), # Varka Silenos Warrior
    21360 => DropInfo.new(509, 2), # Varka Silenos Medium
    21361 => DropInfo.new(518, 2), # Varka Silenos Magus
    21362 => DropInfo.new(518, 2), # Varka Silenos Officer
    21364 => DropInfo.new(527, 2), # Varka Silenos Seer
    21365 => DropInfo.new(500, 3), # Varka Silenos Great Magus
    21366 => DropInfo.new(500, 3), # Varka Silenos General
    21368 => DropInfo.new(508, 3), # Varka Silenos Great Seer
    21369 => DropInfo.new(628, 2), # Varka's Commander
    21370 => DropInfo.new(604, 2), # Varka's Elite Guard
    21371 => DropInfo.new(627, 3), # Varka's Head Magus
    21372 => DropInfo.new(604, 3), # Varka's Head Guard
    21373 => DropInfo.new(649, 3), # Varka's Prophet
    21374 => DropInfo.new(626, 3), # Prophet's Guard
    21375 => DropInfo.new(626, 3)  # Disciple of Prophet
  }
  # Items
  private VARKA_BADGE_SOLDIER = 7216
  private VARKA_BADGE_OFFICER = 7217
  private VARKA_BADGE_CAPTAIN = 7218
  private VALOR_TOTEM = 7219
  private WISDOM_TOTEM = 7220
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
    0,   # cond 1
    100, # cond 2
    200, # cond 3
    300, # cond 4
    400  # cond 5
  }
  private CAPTAIN_BADGE_COUNT = {
    0,   # cond 1
    0,   # cond 2
    100, # cond 3
    200, # cond 4
    200  # cond 5
  }

  def initialize
    super(605, self.class.simple_name, "Alliance with Ketra Orcs")

    add_start_npc(WAHKAN)
    add_talk_id(WAHKAN)
    add_kill_id(MOBS.keys)
    register_quest_items(
      VARKA_BADGE_SOLDIER, VARKA_BADGE_OFFICER, VARKA_BADGE_CAPTAIN
    )
  end

  private def can_get_item?(st, item_id) : Bool
    case item_id
    when VARKA_BADGE_SOLDIER
      count = SOLDIER_BADGE_COUNT[st.cond - 1]
    when VARKA_BADGE_OFFICER
      count = OFFICER_BADGE_COUNT[st.cond - 1]
    when VARKA_BADGE_CAPTAIN
      count = CAPTAIN_BADGE_COUNT[st.cond - 1]
    else
      return false
    end

    st.get_quest_items_count(item_id) < count
  end

  def on_adv_event(event, npc, pc)
    pc = pc.not_nil!
    unless st = get_quest_state(pc, false)
      return
    end

    html = event
    case event
    when "31371-12a.html", "31371-12b.html", "31371-25.html"
      # do nothing
    when "31371-04.htm"
      if has_at_least_one_quest_item?(pc, VARKA_MARKS)
        return "31371-03.htm"
      end
      st.state = State::STARTED
      st.play_sound(Sound::ITEMSOUND_QUEST_ACCEPT)
      KETRA_MARKS.each_with_index do |mark, i|
        if st.has_quest_items?(mark)
          st.set_cond(i + 2)
          return "31371-0#{i + 5}.htm"
        end
      end
      st.set_cond(1)
    when "31371-12.html"
      if st.get_quest_items_count(VARKA_BADGE_SOLDIER) < SOLDIER_BADGE_COUNT[0]
        return get_no_quest_msg(pc)
      end
      st.take_items(VARKA_BADGE_SOLDIER, -1)
      st.give_items(KETRA_MARKS[0], 1)
      st.set_cond(2, true)
    when "31371-15.html"
      if st.get_quest_items_count(VARKA_BADGE_SOLDIER) < SOLDIER_BADGE_COUNT[1] || st.get_quest_items_count(VARKA_BADGE_OFFICER) < OFFICER_BADGE_COUNT[1]
        return get_no_quest_msg(pc)
      end
      take_items(pc, -1, {VARKA_BADGE_SOLDIER, VARKA_BADGE_OFFICER, KETRA_MARKS[0]})
      st.give_items(KETRA_MARKS[1], 1)
      st.set_cond(3, true)
    when "31371-18.html"
      if st.get_quest_items_count(VARKA_BADGE_SOLDIER) < SOLDIER_BADGE_COUNT[2] || st.get_quest_items_count(VARKA_BADGE_OFFICER) < OFFICER_BADGE_COUNT[2] || st.get_quest_items_count(VARKA_BADGE_CAPTAIN) < CAPTAIN_BADGE_COUNT[2]
        return get_no_quest_msg(pc)
      end
      take_items(pc, -1, {VARKA_BADGE_SOLDIER, VARKA_BADGE_OFFICER, VARKA_BADGE_CAPTAIN, KETRA_MARKS[1]})
      st.give_items(KETRA_MARKS[2], 1)
      st.set_cond(4, true)
    when "31371-21.html"
      if !st.has_quest_items?(VALOR_TOTEM) || st.get_quest_items_count(VARKA_BADGE_SOLDIER) < SOLDIER_BADGE_COUNT[3] || st.get_quest_items_count(VARKA_BADGE_OFFICER) < OFFICER_BADGE_COUNT[3] || st.get_quest_items_count(VARKA_BADGE_CAPTAIN) < CAPTAIN_BADGE_COUNT[3]
        return get_no_quest_msg(pc)
      end
      take_items(pc, -1, {VARKA_BADGE_SOLDIER, VARKA_BADGE_OFFICER, VARKA_BADGE_CAPTAIN, VALOR_TOTEM, KETRA_MARKS[2]})
      st.give_items(KETRA_MARKS[3], 1)
      st.set_cond(5, true)
    when "31371-26.html"
      take_items(pc, -1, KETRA_MARKS)
      take_items(pc, -1, {VALOR_TOTEM, WISDOM_TOTEM})
      st.exit_quest(true, true)
    else
      html = nil
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    if m = get_random_party_member_state(killer, State::STARTED)
      st = get_quest_state!(m, false)
      info = MOBS[npc.id]
      if st.cond >= info.min_cond && st.cond < 6
        if can_get_item?(st, info.item_id) && Rnd.rand(1000) < info.chance
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
      html = pc.level >= MIN_LEVEL ? "31371-01.htm" : "31371-02.htm"
    when State::STARTED
      case st.cond
      when 1
        if st.get_quest_items_count(VARKA_BADGE_SOLDIER) >= SOLDIER_BADGE_COUNT[0]
          html = "31371-11.html"
        else
          html = "31371-10.html"
        end
      when 2
        if st.has_quest_items?(KETRA_MARKS[0]) && st.get_quest_items_count(VARKA_BADGE_SOLDIER) >= SOLDIER_BADGE_COUNT[1] && st.get_quest_items_count(VARKA_BADGE_OFFICER) >= OFFICER_BADGE_COUNT[1]
          html = "31371-14.html"
        else
          html = "31371-13.html"
        end
      when 3
        if st.has_quest_items?(KETRA_MARKS[1]) && st.get_quest_items_count(VARKA_BADGE_SOLDIER) >= SOLDIER_BADGE_COUNT[2] && st.get_quest_items_count(VARKA_BADGE_OFFICER) >= OFFICER_BADGE_COUNT[2] && st.get_quest_items_count(VARKA_BADGE_CAPTAIN) >= CAPTAIN_BADGE_COUNT[2]
          html = "31371-17.html"
        else
          html = "31371-16.html"
        end
      when 4
        if has_quest_items?(pc, KETRA_MARKS[2], VALOR_TOTEM) && st.get_quest_items_count(VARKA_BADGE_SOLDIER) >= SOLDIER_BADGE_COUNT[3] && st.get_quest_items_count(VARKA_BADGE_OFFICER) >= OFFICER_BADGE_COUNT[3] && st.get_quest_items_count(VARKA_BADGE_CAPTAIN) >= CAPTAIN_BADGE_COUNT[3]
          html = "31371-20.html"
        else
          html = "31371-19.html"
        end
      when 5
        if !st.has_quest_items?(KETRA_MARKS[3]) || !st.has_quest_items?(WISDOM_TOTEM) || st.get_quest_items_count(VARKA_BADGE_SOLDIER) < SOLDIER_BADGE_COUNT[4] || st.get_quest_items_count(VARKA_BADGE_OFFICER) < OFFICER_BADGE_COUNT[4] || st.get_quest_items_count(VARKA_BADGE_CAPTAIN) < CAPTAIN_BADGE_COUNT[4]
          return "31371-22.html"
        end
        st.set_cond(6, true)
        take_items(pc, -1, {VARKA_BADGE_SOLDIER, VARKA_BADGE_OFFICER, VARKA_BADGE_CAPTAIN, WISDOM_TOTEM, KETRA_MARKS[3]})
        st.give_items(KETRA_MARKS[4], 1)
        html = "31371-23.html"
      when 6
        if st.has_quest_items?(KETRA_MARKS[4])
          html = "31371-24.html"
        end
      end
    end

    html || get_no_quest_msg(pc)
  end
end
