class Scripts::Q00213_TrialOfTheSeeker < Quest
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
    add_talk_id(
      MASTER_DUFNER, MASTER_TERRY, BLACKSMITH_BRUNON, TRADER_VIKTOR,
      MAGISTER_MARINA
    )
    add_kill_id(
      ANT_CAPTAIN, ANT_WARRIOR_CAPTAIN, MEDUSA, NEER_GHOUL_BERSERKER,
      OL_MAHUM_CAPTAIN, MARSH_STAKATO_DRONE, TURAK_BUGBEAR_WARRIOR,
      BREKA_ORC_OVERLORD, TUREK_ORC_WARLORD, LETO_LIZARDMAN_WARRIOR
    )
    register_quest_items(
      DUFNERS_LETTER, TERRYS_1ST_ORDER, TERRYS_2ND_ORDER, TERRYS_LETTER,
      VIKTORS_LETTER, HAWKEYES_LETTER, MYSTERIOUS_SPIRIT_ORE,
      OL_MAHUM_SPIRIT_ORE, TUREK_SPIRIT_ORE, ANT_SPIRIT_ORE,
      TURAK_BUGBEAR_SPIRIT_ORE, TERRY_BOX, VIKTORS_REQUEST, MEDUSA_SCALES,
      SHILENS_SPIRIT_ORE, ANALYSIS_REQUEST, MARINAS_LETTER, EXPERIMENT_TOOLS,
      ANALYSIS_RESULT, TERRYS_3RD_ORDER, LIST_OF_HOST, ABYSS_SPIRIT_ORE1,
      ABYSS_SPIRIT_ORE2, ABYSS_SPIRIT_ORE3, ABYSS_SPIRIT_ORE4, TERRYS_REPORT
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        unless has_quest_items?(pc, DUFNERS_LETTER)
          give_items(pc, DUFNERS_LETTER, 1)
        end
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 128)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30106-05a.htm"
        else
          html = "30106-05.htm"
        end
      end
    when "30106-04.htm", "30064-02.html", "30064-07.html", "30064-16.html",
         "30064-17.html", "30064-19.html", "30684-02.html", "30684-03.html",
         "30684-04.html", "30684-06.html", "30684-07.html", "30684-08.html",
         "30684-09.html", "30684-10.html"
      html = event
    when "30064-03.html"
      if has_quest_items?(pc, DUFNERS_LETTER)
        take_items(pc, DUFNERS_LETTER, 1)
        give_items(pc, TERRYS_1ST_ORDER, 1)
        qs.set_cond(2, true)
        html = event
      end
    when "30064-06.html"
      if has_quest_items?(pc, TERRYS_1ST_ORDER)
        take_items(pc, TERRYS_1ST_ORDER, 1)
        give_items(pc, TERRYS_2ND_ORDER, 1)
        take_items(pc, MYSTERIOUS_SPIRIT_ORE, 1)
        qs.set_cond(4, true)
        html = event
      end
    when "30064-10.html"
      give_items(pc, TERRYS_LETTER, 1)
      take_items(pc, OL_MAHUM_SPIRIT_ORE, 1)
      take_items(pc, TUREK_SPIRIT_ORE, 1)
      take_items(pc, ANT_SPIRIT_ORE, 1)
      take_items(pc, TURAK_BUGBEAR_SPIRIT_ORE, 1)
      take_items(pc, TERRYS_2ND_ORDER, 1)
      give_items(pc, TERRY_BOX, 1)
      qs.set_cond(6, true)
      html = event
    when "30064-18.html"
      if has_quest_items?(pc, ANALYSIS_RESULT)
        take_items(pc, ANALYSIS_RESULT, 1)
        give_items(pc, LIST_OF_HOST, 1)
        qs.set_cond(15, true)
        html = event
      end
    when "30684-05.html"
      if has_quest_items?(pc, TERRYS_LETTER)
        take_items(pc, TERRYS_LETTER, 1)
        give_items(pc, VIKTORS_LETTER, 1)
        qs.set_cond(7, true)
        html = event
      end
    when "30684-11.html"
      take_items(pc, TERRYS_LETTER, 1)
      take_items(pc, TERRY_BOX, 1)
      take_items(pc, HAWKEYES_LETTER, 1)
      take_items(pc, VIKTORS_LETTER, 1)
      give_items(pc, VIKTORS_REQUEST, 1)
      qs.set_cond(9, true)
      html = event
    when "30684-15.html"
      take_items(pc, VIKTORS_REQUEST, 1)
      take_items(pc, MEDUSA_SCALES, -1)
      give_items(pc, SHILENS_SPIRIT_ORE, 1)
      give_items(pc, ANALYSIS_REQUEST, 1)
      qs.set_cond(11, true)
      html = event
    when "30715-02.html"
      take_items(pc, SHILENS_SPIRIT_ORE, 1)
      take_items(pc, ANALYSIS_REQUEST, 1)
      give_items(pc, MARINAS_LETTER, 1)
      qs.set_cond(12, true)
      html = event
    when "30715-05.html"
      take_items(pc, EXPERIMENT_TOOLS, 1)
      give_items(pc, ANALYSIS_RESULT, 1)
      qs.set_cond(14, true)
      html = event
    else
      # [automatically added else]
    end


    html
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
      else
        # [automatically added else]
      end

    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)
    if qs.created?
      if npc.id == MASTER_DUFNER
        if pc.class_id.rogue? || pc.class_id.elven_scout? || pc.class_id.assassin?
          if pc.level < MIN_LVL
            html = "30106-02.html"
          else
            html = "30106-03.htm"
          end
        else
          html = "30106-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MASTER_DUFNER
        if has_quest_items?(pc, DUFNERS_LETTER) && !has_quest_items?(pc, TERRYS_REPORT)
          html = "30106-06.html"
        elsif !has_at_least_one_quest_item?(pc, DUFNERS_LETTER, TERRYS_REPORT)
          html = "30106-07.html"
        elsif has_quest_items?(pc, TERRYS_REPORT) && !has_quest_items?(pc, DUFNERS_LETTER)
          give_adena(pc, 187606, true)
          give_items(pc, MARK_OF_SEEKER, 1)
          add_exp_and_sp(pc, 1029478, 66768)
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          html = "30106-08.html"
        end
      when MASTER_TERRY
        if has_quest_items?(pc, DUFNERS_LETTER)
          html = "30064-01.html"
        elsif has_quest_items?(pc, TERRYS_1ST_ORDER)
          if !has_quest_items?(pc, MYSTERIOUS_SPIRIT_ORE)
            html = "30064-04.html"
          else
            html = "30064-05.html"
          end
        elsif has_quest_items?(pc, TERRYS_2ND_ORDER)
          if get_quest_items_count(pc, OL_MAHUM_SPIRIT_ORE) + get_quest_items_count(pc, TUREK_SPIRIT_ORE) + get_quest_items_count(pc, ANT_SPIRIT_ORE) + get_quest_items_count(pc, TURAK_BUGBEAR_SPIRIT_ORE) < 4
            html = "30064-08.html"
          else
            html = "30064-09.html"
          end
        elsif has_quest_items?(pc, TERRYS_LETTER)
          html = "30064-11.html"
        elsif has_quest_items?(pc, VIKTORS_LETTER)
          take_items(pc, VIKTORS_LETTER, 1)
          give_items(pc, HAWKEYES_LETTER, 1)
          qs.set_cond(8, true)
          html = "30064-12.html"
        elsif has_quest_items?(pc, HAWKEYES_LETTER)
          html = "30064-13.html"
        elsif has_at_least_one_quest_item?(pc, VIKTORS_REQUEST, ANALYSIS_REQUEST, MARINAS_LETTER, EXPERIMENT_TOOLS)
          html = "30064-14.html"
        elsif has_quest_items?(pc, ANALYSIS_RESULT)
          html = "30064-15.html"
        elsif has_quest_items?(pc, TERRYS_3RD_ORDER)
          if pc.level < LEVEL
            html = "30064-20.html"
          else
            take_items(pc, TERRYS_3RD_ORDER, 1)
            give_items(pc, LIST_OF_HOST, 1)
            qs.set_cond(15, true)
            html = "30064-21.html"
          end
        elsif has_quest_items?(pc, LIST_OF_HOST)
          if get_quest_items_count(pc, ABYSS_SPIRIT_ORE1) + get_quest_items_count(pc, ABYSS_SPIRIT_ORE2) + get_quest_items_count(pc, ABYSS_SPIRIT_ORE3) + get_quest_items_count(pc, ABYSS_SPIRIT_ORE4) < 4
            html = "30064-22.html"
          else
            take_items(pc, LIST_OF_HOST, 1)
            take_items(pc, ABYSS_SPIRIT_ORE1, 1)
            take_items(pc, ABYSS_SPIRIT_ORE2, 1)
            take_items(pc, ABYSS_SPIRIT_ORE3, 1)
            take_items(pc, ABYSS_SPIRIT_ORE4, 1)
            give_items(pc, TERRYS_REPORT, 1)
            qs.set_cond(17, true)
            html = "30064-23.html"
          end
        elsif has_quest_items?(pc, TERRYS_REPORT)
          html = "30064-24.html"
        end
      when BLACKSMITH_BRUNON
        if has_quest_items?(pc, MARINAS_LETTER)
          take_items(pc, MARINAS_LETTER, 1)
          give_items(pc, EXPERIMENT_TOOLS, 1)
          qs.set_cond(13, true)
          html = "30526-01.html"
        elsif has_quest_items?(pc, EXPERIMENT_TOOLS)
          html = "30526-02.html"
        end
      when TRADER_VIKTOR
        if has_quest_items?(pc, TERRYS_LETTER)
          html = "30684-01.html"
        elsif has_quest_items?(pc, HAWKEYES_LETTER)
          html = "30684-12.html"
        elsif has_quest_items?(pc, VIKTORS_REQUEST)
          if get_quest_items_count(pc, MEDUSA_SCALES) < 10
            html = "30684-13.html"
          else
            html = "30684-14.html"
          end
        elsif has_quest_items?(pc, SHILENS_SPIRIT_ORE, ANALYSIS_REQUEST)
          html = "30684-16.html"
        elsif has_quest_items?(pc, MARINAS_LETTER, EXPERIMENT_TOOLS, ANALYSIS_REQUEST, TERRYS_REPORT)
          html = "30684-17.html"
        elsif has_quest_items?(pc, VIKTORS_LETTER)
          html = "30684-05.html"
        end
      when MAGISTER_MARINA
        if has_quest_items?(pc, SHILENS_SPIRIT_ORE, ANALYSIS_REQUEST)
          html = "30715-01.html"
        elsif has_quest_items?(pc, MARINAS_LETTER)
          html = "30715-03.html"
        elsif has_quest_items?(pc, EXPERIMENT_TOOLS)
          html = "30715-04.html"
        elsif has_quest_items?(pc, ANALYSIS_RESULT)
          html = "30715-06.html"
        end
      else
        # [automatically added else]
      end

    elsif qs.completed?
      if npc.id == MASTER_DUFNER
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
