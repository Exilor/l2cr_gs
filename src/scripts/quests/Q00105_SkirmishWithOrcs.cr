class Quests::Q00105_SkirmishWithOrcs < Quest
  # NPC
  private KENDNELL = 30218
  # Items
  private KENDELLS_1ST_ORDER = 1836
  private KENDELLS_2ND_ORDER = 1837
  private KENDELLS_3RD_ORDER = 1838
  private KENDELLS_4TH_ORDER = 1839
  private KENDELLS_5TH_ORDER = 1840
  private KENDELLS_6TH_ORDER = 1841
  private KENDELLS_7TH_ORDER = 1842
  private KENDELLS_8TH_ORDER = 1843
  private KABOO_CHIEFS_1ST_TORQUE = 1844
  private KABOO_CHIEFS_2ST_TORQUE = 1845
  private MONSTER_DROP = {
    27059 => KENDELLS_1ST_ORDER, # Uoph (Kaboo Chief)
    27060 => KENDELLS_2ND_ORDER, # Kracha (Kaboo Chief)
    27061 => KENDELLS_3RD_ORDER, # Batoh (Kaboo Chief)
    27062 => KENDELLS_4TH_ORDER, # Tanukia (Kaboo Chief)
    27064 => KENDELLS_5TH_ORDER, # Turel (Kaboo Chief)
    27065 => KENDELLS_6TH_ORDER, # Roko (Kaboo Chief)
    27067 => KENDELLS_7TH_ORDER, # Kamut (Kaboo Chief)
    27068 => KENDELLS_8TH_ORDER  # Murtika (Kaboo Chief)
  }
  private KENDNELLS_ORDERS = {
    KENDELLS_1ST_ORDER,
    KENDELLS_2ND_ORDER,
    KENDELLS_3RD_ORDER,
    KENDELLS_4TH_ORDER,
    KENDELLS_5TH_ORDER,
    KENDELLS_6TH_ORDER,
    KENDELLS_7TH_ORDER,
    KENDELLS_8TH_ORDER
  }
  # Misc
  private MIN_LVL = 10

  def initialize
    super(105, self.class.simple_name, "Skirmish with Orcs")

    add_start_npc(KENDNELL)
    add_talk_id(KENDNELL)
    add_kill_id(MONSTER_DROP.keys)
    register_quest_items(KENDNELLS_ORDERS)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless st = get_quest_state(player, false)

    case event
    when "30218-04.html"
      if st.created?
        st.start_quest
        st.give_items(KENDNELLS_ORDERS[rand(0..3)], 1)
        htmltext = event
      end
    when "30218-05.html"
      htmltext = event
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)
    if st && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when 27059, 27060, 27061, 27062
        if st.cond?(1) && st.has_quest_items?(MONSTER_DROP[npc.id])
          st.give_items(KABOO_CHIEFS_1ST_TORQUE, 1)
          st.set_cond(2, true)
        end
      when 27064, 27065, 27067, 27068
        if st.cond?(3) && st.has_quest_items?(MONSTER_DROP[npc.id])
          st.give_items(KABOO_CHIEFS_2ST_TORQUE, 1)
          st.set_cond(4, true)
        end
      end
    end

    super
  end

  def on_talk(npc, talker)
    st = get_quest_state(talker, true)
    htmltext = get_no_quest_msg(talker)
    return htmltext unless st

    case st.state
    when State::CREATED
      if talker.race.elf?
        htmltext = talker.level >= MIN_LVL ? "30218-03.htm" : "30218-02.htm"
      else
        htmltext = "30218-01.htm"
      end
    when State::STARTED
      if has_at_least_one_quest_item?(talker, KENDELLS_1ST_ORDER, KENDELLS_2ND_ORDER, KENDELLS_3RD_ORDER, KENDELLS_4TH_ORDER)
        htmltext = "30218-06.html"
      end
      if st.cond?(2) && st.has_quest_items?(KABOO_CHIEFS_1ST_TORQUE)
        4.times do |i|
          st.take_items(KENDNELLS_ORDERS[i], -1)
        end
        st.take_items(KABOO_CHIEFS_1ST_TORQUE, 1)
        st.give_items(KENDNELLS_ORDERS[rand(4..7)], 1)
        st.set_cond(3, true)
        htmltext = "30218-07.html"
      end
      if has_at_least_one_quest_item?(talker, KENDELLS_5TH_ORDER, KENDELLS_6TH_ORDER, KENDELLS_7TH_ORDER, KENDELLS_8TH_ORDER)
        htmltext = "30218-08.html"
      end
      if st.cond?(4) && st.has_quest_items?(KABOO_CHIEFS_2ST_TORQUE)
        Q00281_HeadForTheHills.give_newbie_reward(talker)
        talker.send_packet(SocialAction.new(talker.l2id, 3))
        st.give_adena(17599, true)
        st.add_exp_and_sp(41478, 3555)
        st.exit_quest(false, true)
        htmltext = "30218-09.html"
      end
    when State::COMPLETED
      htmltext = get_already_completed_msg(talker)
    end

    htmltext
  end
end
