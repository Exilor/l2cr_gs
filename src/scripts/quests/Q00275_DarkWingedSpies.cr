class Quests::Q00275_DarkWingedSpies < Quest
  # Npc
  private NERUGA_CHIEF_TANTUS = 30567
  # Items
  private DARKWING_BAT_FANG = 1478
  private VARANGKAS_PARASITE = 1479
  # Monsters
  private DARKWING_BAT = 20316
  private VARANGKAS_TRACKER = 27043
  # Misc
  private MIN_LVL = 11
  private FANG_PRICE = 60
  private MAX_BAT_FANG_COUNT = 70

  def initialize
    super(275, self.class.simple_name, "Dark Winged Spies")

    add_start_npc(NERUGA_CHIEF_TANTUS)
    add_talk_id(NERUGA_CHIEF_TANTUS)
    add_kill_id(DARKWING_BAT, VARANGKAS_TRACKER)
    add_see_creature_id(VARANGKAS_TRACKER)
    register_quest_items(DARKWING_BAT_FANG, VARANGKAS_PARASITE)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless st = get_quest_state(player, false)

    if event == "30567-03.htm"
      st.start_quest
      event
    end
  end

  def on_kill(npc, killer, is_summon)
    st = get_quest_state(killer, false)

    if st && st.cond?(1) && Util.in_range?(1500, npc, killer, true)
       count = st.get_quest_items_count(DARKWING_BAT_FANG)

      case npc.id
      when DARKWING_BAT
        if st.give_item_randomly(DARKWING_BAT_FANG, 1, MAX_BAT_FANG_COUNT, 1, true)
          st.set_cond(2)
        elsif count > 10 && count < 66 && Rnd.rand(100) < 10
          st.add_spawn(VARANGKAS_TRACKER)
          st.give_items(VARANGKAS_PARASITE, 1)
        end
      when VARANGKAS_TRACKER
        if count < 66 && st.has_quest_items?(VARANGKAS_PARASITE)
          if st.give_item_randomly(DARKWING_BAT_FANG, 5, MAX_BAT_FANG_COUNT, 1, true)
            st.set_cond(2)
          end
          st.take_items(VARANGKAS_PARASITE, -1)
        end
      end
    end

    super
  end

  def on_see_creature(npc, creature, is_summon)
    if creature.player?
      npc.set_running
      npc.as(L2Attackable).add_damage_hate(creature, 0, 1i64)
      npc.set_intention(AI::ATTACK, creature)
    end

    super
  end

  def on_talk(npc, talker)
    st = get_quest_state!(talker)
    htmltext = get_no_quest_msg(talker)

    case st.state
    when State::CREATED
      htmltext = talker.race.orc? ? talker.level >= MIN_LVL ? "30567-02.htm" : "30567-01.htm" : "30567-00.htm"
    when State::STARTED
      case st.cond
      when 1
        htmltext = "30567-05.html"
      when 2
        count = st.get_quest_items_count(DARKWING_BAT_FANG)
        if count >= MAX_BAT_FANG_COUNT
          st.give_adena(count * FANG_PRICE, true)
          st.exit_quest(true, true)
          htmltext = "30567-05.html"
        end
      end
    end

    htmltext
  end
end
