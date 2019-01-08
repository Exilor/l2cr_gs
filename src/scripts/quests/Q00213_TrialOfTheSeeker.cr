class Quests::Q00213_TrialOfTheSeeker < Quest
  # NPCs
  private MASTER_TERRY = 30064
  private MASTER_DUFNER = 30106
  private BLACKSMITH_BRUNON = 30526
  private TRADER_VIKTOR = 30684
  private MAGISTER_MARINA = 30715
  # Items
  private DUFNERS_LETTER = 2647
  private TERRYS_1ST_ORDER = 2648
  private TERRYS_2ND_ORDER = 2649
  private TERRYS_LETTER = 2650
  private VIKTORS_LETTER = 2651
  private HAWKEYES_LETTER = 2652
  private MYSTERIOUS_SPIRIT_ORE = 2653
  private OL_MAHUM_SPIRIT_ORE = 2654
  private TUREK_SPIRIT_ORE = 2655
  private ANT_SPIRIT_ORE = 2656
  private TURAK_BUGBEAR_SPIRIT_ORE = 2657
  private TERRY_BOX = 2658
  private VIKTORS_REQUEST = 2659
  private MEDUSA_SCALES = 2660
  private SHILENS_SPIRIT_ORE = 2661
  private ANALYSIS_REQUEST = 2662
  private MARINAS_LETTER = 2663
  private EXPERIMENT_TOOLS = 2664
  private ANALYSIS_RESULT = 2665
  private TERRYS_3RD_ORDER = 2666
  private LIST_OF_HOST = 2667
  private ABYSS_SPIRIT_ORE1 = 2668
  private ABYSS_SPIRIT_ORE2 = 2669
  private ABYSS_SPIRIT_ORE3 = 2670
  private ABYSS_SPIRIT_ORE4 = 2671
  private TERRYS_REPORT = 2672
  # Reward
  private MARK_OF_SEEKER = 2673
  private DIMENSIONAL_DIAMOND = 7562
  # Monsters
  private ANT_CAPTAIN = 20080
  private ANT_WARRIOR_CAPTAIN = 20088
  private MEDUSA = 20158
  private NEER_GHOUL_BERSERKER = 20198
  private OL_MAHUM_CAPTAIN = 20211
  private MARSH_STAKATO_DRONE = 20234
  private TURAK_BUGBEAR_WARRIOR = 20249
  private BREKA_ORC_OVERLORD = 20270
  private TUREK_ORC_WARLORD = 20495
  private LETO_LIZARDMAN_WARRIOR = 20580
  # Misc
  private MIN_LVL = 35
  private LEVEL = 36

  def initialize
    super(213, self.class.simple_name, "Trial Of The Seeker")

    add_start_npc(MASTER_DUFNER)
    add_talk_id(MASTER_DUFNER, MASTER_TERRY, BLACKSMITH_BRUNON, TRADER_VIKTOR, MAGISTER_MARINA)
    add_kill_id(ANT_CAPTAIN, ANT_WARRIOR_CAPTAIN, MEDUSA, NEER_GHOUL_BERSERKER, OL_MAHUM_CAPTAIN, MARSH_STAKATO_DRONE, TURAK_BUGBEAR_WARRIOR, BREKA_ORC_OVERLORD, TUREK_ORC_WARLORD, LETO_LIZARDMAN_WARRIOR)
    register_quest_items(DUFNERS_LETTER, TERRYS_1ST_ORDER, TERRYS_2ND_ORDER, TERRYS_LETTER, VIKTORS_LETTER, HAWKEYES_LETTER, MYSTERIOUS_SPIRIT_ORE, OL_MAHUM_SPIRIT_ORE, TUREK_SPIRIT_ORE, ANT_SPIRIT_ORE, TURAK_BUGBEAR_SPIRIT_ORE, TERRY_BOX, VIKTORS_REQUEST, MEDUSA_SCALES, SHILENS_SPIRIT_ORE, ANALYSIS_REQUEST, MARINAS_LETTER, EXPERIMENT_TOOLS, ANALYSIS_RESULT, TERRYS_3RD_ORDER, LIST_OF_HOST, ABYSS_SPIRIT_ORE1, ABYSS_SPIRIT_ORE2, ABYSS_SPIRIT_ORE3, ABYSS_SPIRIT_ORE4, TERRYS_REPORT)
  end

  def on_adv_event(event, npc, player)
    return unless player
    return unless qs = get_quest_state(player, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        unless has_quest_items?(player, DUFNERS_LETTER)
          give_items(player, DUFNERS_LETTER, 1)
        end
        play_sound(player, Sound::ITEMSOUND_QUEST_MIDDLE)
        if player.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(player, DIMENSIONAL_DIAMOND, 128)
          player.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          htmltext = "30106-05a.htm"
        else
          htmltext = "30106-05.htm"
        end
      end
    when "30106-04.htm", "30064-02.html", "30064-07.html", "30064-16.html",
         "30064-17.html", "30064-19.html", "30684-02.html", "30684-03.html",
         "30684-04.html", "30684-06.html", "30684-07.html", "30684-08.html",
         "30684-09.html", "30684-10.html"
      htmltext = event
    when "30064-03.html"
      if has_quest_items?(player, DUFNERS_LETTER)
        take_items(player, DUFNERS_LETTER, 1)
        give_items(player, TERRYS_1ST_ORDER, 1)
        qs.set_cond(2, true)
        htmltext = event
      end
    when "30064-06.html"
      if has_quest_items?(player, TERRYS_1ST_ORDER)
        take_items(player, TERRYS_1ST_ORDER, 1)
        give_items(player, TERRYS_2ND_ORDER, 1)
        take_items(player, MYSTERIOUS_SPIRIT_ORE, 1)
        qs.set_cond(4, true)
        htmltext = event
      end
    when "30064-10.html"
      give_items(player, TERRYS_LETTER, 1)
      take_items(player, OL_MAHUM_SPIRIT_ORE, 1)
      take_items(player, TUREK_SPIRIT_ORE, 1)
      take_items(player, ANT_SPIRIT_ORE, 1)
      take_items(player, TURAK_BUGBEAR_SPIRIT_ORE, 1)
      take_items(player, TERRYS_2ND_ORDER, 1)
      give_items(player, TERRY_BOX, 1)
      qs.set_cond(6, true)
      htmltext = event
    when "30064-18.html"
      if has_quest_items?(player, ANALYSIS_RESULT)
        take_items(player, ANALYSIS_RESULT, 1)
        give_items(player, LIST_OF_HOST, 1)
        qs.set_cond(15, true)
        htmltext = event
      end
    when "30684-05.html"
      if has_quest_items?(player, TERRYS_LETTER)
        take_items(player, TERRYS_LETTER, 1)
        give_items(player, VIKTORS_LETTER, 1)
        qs.set_cond(7, true)
        htmltext = event
      end
    when "30684-11.html"
      take_items(player, TERRYS_LETTER, 1)
      take_items(player, TERRY_BOX, 1)
      take_items(player, HAWKEYES_LETTER, 1)
      take_items(player, VIKTORS_LETTER, 1)
      give_items(player, VIKTORS_REQUEST, 1)
      qs.set_cond(9, true)
      htmltext = event
    when "30684-15.html"
      take_items(player, VIKTORS_REQUEST, 1)
      take_items(player, MEDUSA_SCALES, -1)
      give_items(player, SHILENS_SPIRIT_ORE, 1)
      give_items(player, ANALYSIS_REQUEST, 1)
      qs.set_cond(11, true)
      htmltext = event
    when "30715-02.html"
      take_items(player, SHILENS_SPIRIT_ORE, 1)
      take_items(player, ANALYSIS_REQUEST, 1)
      give_items(player, MARINAS_LETTER, 1)
      qs.set_cond(12, true)
      htmltext = event
    when "30715-05.html"
      take_items(player, EXPERIMENT_TOOLS, 1)
      give_items(player, ANALYSIS_RESULT, 1)
      qs.set_cond(14, true)
      htmltext = event
    end

    htmltext
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when ANT_CAPTAIN
        if has_quest_items?(killer, TERRYS_2ND_ORDER) && !has_quest_items?(killer, ANT_SPIRIT_ORE)
          give_items(killer, ANT_SPIRIT_ORE, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          if has_quest_items?(killer, OL_MAHUM_SPIRIT_ORE, TUREK_SPIRIT_ORE, TURAK_BUGBEAR_SPIRIT_ORE)
            qs.set_cond(5)
          end
        end
      when ANT_WARRIOR_CAPTAIN
        if has_quest_items?(killer, LIST_OF_HOST) && !has_quest_items?(killer, ABYSS_SPIRIT_ORE3)
          give_items(killer, ABYSS_SPIRIT_ORE3, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          if has_quest_items?(killer, ABYSS_SPIRIT_ORE1, ABYSS_SPIRIT_ORE2, ABYSS_SPIRIT_ORE4)
            qs.set_cond(16)
          end
        end
      when MEDUSA
        if has_quest_items?(killer, VIKTORS_REQUEST) && (get_quest_items_count(killer, MEDUSA_SCALES) < 10)
          give_items(killer, MEDUSA_SCALES, 1)
          if get_quest_items_count(killer, MEDUSA_SCALES) == 10
            qs.set_cond(10, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when NEER_GHOUL_BERSERKER
        if has_quest_items?(killer, TERRYS_1ST_ORDER) && !has_quest_items?(killer, MYSTERIOUS_SPIRIT_ORE)
          if Rnd.rand(100) < 50
            give_items(killer, MYSTERIOUS_SPIRIT_ORE, 1)
            qs.set_cond(3, true)
          end
        end
      when OL_MAHUM_CAPTAIN
        if has_quest_items?(killer, TERRYS_2ND_ORDER) && !has_quest_items?(killer, OL_MAHUM_SPIRIT_ORE)
          give_items(killer, OL_MAHUM_SPIRIT_ORE, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          if has_quest_items?(killer, TUREK_SPIRIT_ORE, ANT_SPIRIT_ORE, TURAK_BUGBEAR_SPIRIT_ORE)
            qs.set_cond(5)
          end
        end
      when MARSH_STAKATO_DRONE
        if has_quest_items?(killer, LIST_OF_HOST) && !has_quest_items?(killer, ABYSS_SPIRIT_ORE1)
          give_items(killer, ABYSS_SPIRIT_ORE1, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          if has_quest_items?(killer, ABYSS_SPIRIT_ORE2, ABYSS_SPIRIT_ORE3, ABYSS_SPIRIT_ORE4)
            qs.set_cond(16)
          end
        end
      when TURAK_BUGBEAR_WARRIOR
        if has_quest_items?(killer, TERRYS_2ND_ORDER) && !has_quest_items?(killer, TURAK_BUGBEAR_SPIRIT_ORE)
          give_items(killer, TURAK_BUGBEAR_SPIRIT_ORE, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          if has_quest_items?(killer, OL_MAHUM_SPIRIT_ORE, TUREK_SPIRIT_ORE, ANT_SPIRIT_ORE)
            qs.set_cond(5)
          end
        end
      when BREKA_ORC_OVERLORD
        if has_quest_items?(killer, LIST_OF_HOST) && !has_quest_items?(killer, ABYSS_SPIRIT_ORE2)
          give_items(killer, ABYSS_SPIRIT_ORE2, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          if has_quest_items?(killer, ABYSS_SPIRIT_ORE1, ABYSS_SPIRIT_ORE3, ABYSS_SPIRIT_ORE4)
            qs.set_cond(16)
          end
        end
      when TUREK_ORC_WARLORD
        if has_quest_items?(killer, TERRYS_2ND_ORDER) && !has_quest_items?(killer, TUREK_SPIRIT_ORE)
          give_items(killer, TUREK_SPIRIT_ORE, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          if has_quest_items?(killer, OL_MAHUM_SPIRIT_ORE, ANT_SPIRIT_ORE, TURAK_BUGBEAR_SPIRIT_ORE)
            qs.set_cond(5)
          end
        end
      when LETO_LIZARDMAN_WARRIOR
        if has_quest_items?(killer, LIST_OF_HOST) && !has_quest_items?(killer, ABYSS_SPIRIT_ORE4)
          give_items(killer, ABYSS_SPIRIT_ORE4, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          if has_quest_items?(killer, ABYSS_SPIRIT_ORE1, ABYSS_SPIRIT_ORE2, ABYSS_SPIRIT_ORE3)
            qs.set_cond(16)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, player)
    qs = get_quest_state!(player)
    htmltext = get_no_quest_msg(player)
    if qs.created?
      if npc.id == MASTER_DUFNER
        if player.class_id.rogue? || player.class_id.elven_scout? || player.class_id.assassin?
          if player.level < MIN_LVL
            htmltext = "30106-02.html"
          else
            htmltext = "30106-03.htm"
          end
        else
          htmltext = "30106-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MASTER_DUFNER
        if has_quest_items?(player, DUFNERS_LETTER) && !has_quest_items?(player, TERRYS_REPORT)
          htmltext = "30106-06.html"
        elsif !has_at_least_one_quest_item?(player, DUFNERS_LETTER, TERRYS_REPORT)
          htmltext = "30106-07.html"
        elsif has_quest_items?(player, TERRYS_REPORT) && !has_quest_items?(player, DUFNERS_LETTER)
          give_adena(player, 187606, true)
          give_items(player, MARK_OF_SEEKER, 1)
          add_exp_and_sp(player, 1029478, 66768)
          qs.exit_quest(false, true)
          player.send_packet(SocialAction.new(player.l2id, 3))
          htmltext = "30106-08.html"
        end
      when MASTER_TERRY
        if has_quest_items?(player, DUFNERS_LETTER)
          htmltext = "30064-01.html"
        elsif has_quest_items?(player, TERRYS_1ST_ORDER)
          if !has_quest_items?(player, MYSTERIOUS_SPIRIT_ORE)
            htmltext = "30064-04.html"
          else
            htmltext = "30064-05.html"
          end
        elsif has_quest_items?(player, TERRYS_2ND_ORDER)
          if (get_quest_items_count(player, OL_MAHUM_SPIRIT_ORE) + get_quest_items_count(player, TUREK_SPIRIT_ORE) + get_quest_items_count(player, ANT_SPIRIT_ORE) + get_quest_items_count(player, TURAK_BUGBEAR_SPIRIT_ORE)) < 4
            htmltext = "30064-08.html"
          else
            htmltext = "30064-09.html"
          end
        elsif has_quest_items?(player, TERRYS_LETTER)
          htmltext = "30064-11.html"
        elsif has_quest_items?(player, VIKTORS_LETTER)
          take_items(player, VIKTORS_LETTER, 1)
          give_items(player, HAWKEYES_LETTER, 1)
          qs.set_cond(8, true)
          htmltext = "30064-12.html"
        elsif has_quest_items?(player, HAWKEYES_LETTER)
          htmltext = "30064-13.html"
        elsif has_at_least_one_quest_item?(player, VIKTORS_REQUEST, ANALYSIS_REQUEST, MARINAS_LETTER, EXPERIMENT_TOOLS)
          htmltext = "30064-14.html"
        elsif has_quest_items?(player, ANALYSIS_RESULT)
          htmltext = "30064-15.html"
        elsif has_quest_items?(player, TERRYS_3RD_ORDER)
          if player.level < LEVEL
            htmltext = "30064-20.html"
          else
            take_items(player, TERRYS_3RD_ORDER, 1)
            give_items(player, LIST_OF_HOST, 1)
            qs.set_cond(15, true)
            htmltext = "30064-21.html"
          end
        elsif has_quest_items?(player, LIST_OF_HOST)
          if (get_quest_items_count(player, ABYSS_SPIRIT_ORE1) + get_quest_items_count(player, ABYSS_SPIRIT_ORE2) + get_quest_items_count(player, ABYSS_SPIRIT_ORE3) + get_quest_items_count(player, ABYSS_SPIRIT_ORE4)) < 4
            htmltext = "30064-22.html"
          else
            take_items(player, LIST_OF_HOST, 1)
            take_items(player, ABYSS_SPIRIT_ORE1, 1)
            take_items(player, ABYSS_SPIRIT_ORE2, 1)
            take_items(player, ABYSS_SPIRIT_ORE3, 1)
            take_items(player, ABYSS_SPIRIT_ORE4, 1)
            give_items(player, TERRYS_REPORT, 1)
            qs.set_cond(17, true)
            htmltext = "30064-23.html"
          end
        elsif has_quest_items?(player, TERRYS_REPORT)
          htmltext = "30064-24.html"
        end
      when BLACKSMITH_BRUNON
        if has_quest_items?(player, MARINAS_LETTER)
          take_items(player, MARINAS_LETTER, 1)
          give_items(player, EXPERIMENT_TOOLS, 1)
          qs.set_cond(13, true)
          htmltext = "30526-01.html"
        elsif has_quest_items?(player, EXPERIMENT_TOOLS)
          htmltext = "30526-02.html"
        end
      when TRADER_VIKTOR
        if has_quest_items?(player, TERRYS_LETTER)
          htmltext = "30684-01.html"
        elsif has_quest_items?(player, HAWKEYES_LETTER)
          htmltext = "30684-12.html"
        elsif has_quest_items?(player, VIKTORS_REQUEST)
          if get_quest_items_count(player, MEDUSA_SCALES) < 10
            htmltext = "30684-13.html"
          else
            htmltext = "30684-14.html"
          end
        elsif has_quest_items?(player, SHILENS_SPIRIT_ORE, ANALYSIS_REQUEST)
          htmltext = "30684-16.html"
        elsif has_quest_items?(player, MARINAS_LETTER, EXPERIMENT_TOOLS, ANALYSIS_REQUEST, TERRYS_REPORT)
          htmltext = "30684-17.html"
        elsif has_quest_items?(player, VIKTORS_LETTER)
          htmltext = "30684-05.html"
        end
      when MAGISTER_MARINA
        if has_quest_items?(player, SHILENS_SPIRIT_ORE, ANALYSIS_REQUEST)
          htmltext = "30715-01.html"
        elsif has_quest_items?(player, MARINAS_LETTER)
          htmltext = "30715-03.html"
        elsif has_quest_items?(player, EXPERIMENT_TOOLS)
          htmltext = "30715-04.html"
        elsif has_quest_items?(player, ANALYSIS_RESULT)
          htmltext = "30715-06.html"
        end
      end
    elsif qs.completed?
      if npc.id == MASTER_DUFNER
        htmltext = get_already_completed_msg(player)
      end
    end

    htmltext
  end
end
