class Scripts::Q00214_TrialOfTheScholar < Quest
  # NPCs
  private HIGH_PRIEST_SYLVAIN = 30070
  private CAPTAIN_LUCAS = 30071
  private WAREHOUSE_KEEPER_VALKON = 30103
  private MAGISTER_DIETER = 30111
  private GRAND_MAGISTER_JUREK = 30115
  private TRADER_EDROC = 30230
  private WAREHOUSE_KEEPER_RAUT = 30316
  private BLACKSMITH_POITAN = 30458
  private MAGISTER_MIRIEN = 30461
  private MARIA = 30608
  private ASTROLOGER_CRETA = 30609
  private ELDER_CRONOS = 30610
  private DRUNKARD_TRIFF = 30611
  private ELDER_CASIAN = 30612
  # Items
  private MIRIENS_1ST_SIGIL = 2675
  private MIRIENS_2ND_SIGIL = 2676
  private MIRIENS_3RD_SIGIL = 2677
  private MIRIENS_INSTRUCTION = 2678
  private MARIAS_1ST_LETTER = 2679
  private MARIAS_2ND_LETTER = 2680
  private LUCASS_LETTER = 2681
  private LUCILLAS_HANDBAG = 2682
  private CRETAS_1ST_LETTER = 2683
  private CRERAS_PAINTING1 = 2684
  private CRERAS_PAINTING2 = 2685
  private CRERAS_PAINTING3 = 2686
  private BROWN_SCROLL_SCRAP = 2687
  private CRYSTAL_OF_PURITY1 = 2688
  private HIGH_PRIESTS_SIGIL = 2689
  private GRAND_MAGISTER_SIGIL = 2690
  private CRONOS_SIGIL = 2691
  private SYLVAINS_LETTER = 2692
  private SYMBOL_OF_SYLVAIN = 2693
  private JUREKS_LIST = 2694
  private MONSTER_EYE_DESTROYER_SKIN = 2695
  private SHAMANS_NECKLACE = 2696
  private SHACKLES_SCALP = 2697
  private SYMBOL_OF_JUREK = 2698
  private CRONOS_LETTER = 2699
  private DIETERS_KEY = 2700
  private CRETAS_2ND_LETTER = 2701
  private DIETERS_LETTER = 2702
  private DIETERS_DIARY = 2703
  private RAUTS_LETTER_ENVELOPE = 2704
  private TRIFFS_RING = 2705
  private SCRIPTURE_CHAPTER_1 = 2706
  private SCRIPTURE_CHAPTER_2 = 2707
  private SCRIPTURE_CHAPTER_3 = 2708
  private SCRIPTURE_CHAPTER_4 = 2709
  private VALKONS_REQUEST = 2710
  private POITANS_NOTES = 2711
  private STRONG_LIGUOR = 2713
  private CRYSTAL_OF_PURITY2 = 2714
  private CASIANS_LIST = 2715
  private GHOULS_SKIN = 2716
  private MEDUSAS_BLOOD = 2717
  private FETTERED_SOULS_ICHOR = 2718
  private ENCHANTED_GARGOYLES_NAIL = 2719
  private SYMBOL_OF_CRONOS = 2720
  # Reward
  private MARK_OF_SCHOLAR = 2674
  private DIMENSIONAL_DIAMOND = 7562
  # Monsters
  private MONSTER_EYE_DESTROYER = 20068
  private MEDUSA = 20158
  private GHOUL = 20201
  private SHACKLE1 = 20235
  private BREKA_ORC_SHAMAN = 20269
  private SHACKLE2 = 20279
  private FETTERED_SOUL = 20552
  private GRANDIS = 20554
  private ENCHANTED_GARGOYLE = 20567
  private LETO_LIZARDMAN_WARRIOR = 20580
  # Misc
  private MIN_LVL = 35
  private LEVEL = 36

  def initialize
    super(214, self.class.simple_name, "Trial Of The Scholar")

    add_start_npc(MAGISTER_MIRIEN)
    add_talk_id(
      MAGISTER_MIRIEN, HIGH_PRIEST_SYLVAIN, CAPTAIN_LUCAS,
      WAREHOUSE_KEEPER_VALKON, MAGISTER_DIETER, GRAND_MAGISTER_JUREK,
      TRADER_EDROC, WAREHOUSE_KEEPER_RAUT, BLACKSMITH_POITAN, MARIA,
      ASTROLOGER_CRETA, ELDER_CRONOS, DRUNKARD_TRIFF, ELDER_CASIAN
    )
    add_kill_id(
      MONSTER_EYE_DESTROYER, MEDUSA, GHOUL, SHACKLE1, BREKA_ORC_SHAMAN,
      SHACKLE2, FETTERED_SOUL, GRANDIS, ENCHANTED_GARGOYLE,
      LETO_LIZARDMAN_WARRIOR
    )
    register_quest_items(
      MIRIENS_1ST_SIGIL, MIRIENS_2ND_SIGIL, MIRIENS_3RD_SIGIL,
      MIRIENS_INSTRUCTION, MARIAS_1ST_LETTER, MARIAS_2ND_LETTER, LUCASS_LETTER,
      LUCILLAS_HANDBAG, CRETAS_1ST_LETTER, CRERAS_PAINTING1, CRERAS_PAINTING1,
      CRERAS_PAINTING3, BROWN_SCROLL_SCRAP, CRYSTAL_OF_PURITY1,
      HIGH_PRIESTS_SIGIL, GRAND_MAGISTER_SIGIL, CRONOS_SIGIL,
      SYLVAINS_LETTER, SYMBOL_OF_SYLVAIN, JUREKS_LIST,
      MONSTER_EYE_DESTROYER_SKIN, SHAMANS_NECKLACE, SHACKLES_SCALP,
      SYMBOL_OF_JUREK, CRONOS_LETTER, DIETERS_KEY, CRETAS_2ND_LETTER,
      DIETERS_LETTER, DIETERS_DIARY, RAUTS_LETTER_ENVELOPE, TRIFFS_RING,
      SCRIPTURE_CHAPTER_1, SCRIPTURE_CHAPTER_2, SCRIPTURE_CHAPTER_3,
      SCRIPTURE_CHAPTER_4, VALKONS_REQUEST, POITANS_NOTES, STRONG_LIGUOR,
      CRYSTAL_OF_PURITY2, CASIANS_LIST, GHOULS_SKIN, MEDUSAS_BLOOD,
      FETTERED_SOULS_ICHOR, ENCHANTED_GARGOYLES_NAIL, SYMBOL_OF_CRONOS
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc && (qs = get_quest_state(pc, false))

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        if !has_quest_items?(pc, MIRIENS_1ST_SIGIL)
          give_items(pc, MIRIENS_1ST_SIGIL, 1)
        end
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 168)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30461-04a.htm"
        else
          html = "30461-04.htm"
        end
      end
    when "30103-02.html", "30103-03.html", "30111-02.html", "30111-03.html",
         "30111-04.html", "30111-08.html", "30111-14.html", "30115-02.html",
         "30316-03.html", "30461-09.html", "30608-07.html", "30609-02.html",
         "30609-03.html", "30609-04.html", "30609-08.html", "30609-13.html",
         "30610-02.html", "30610-03.html", "30610-04.html", "30610-05.html",
         "30610-06.html", "30610-07.html", "30610-08.html", "30610-09.html",
         "30610-13.html", "30611-02.html", "30611-03.html", "30611-06.html",
         "30612-03.html"
      html = event
    when "30461-10.html"
      if has_quest_items?(pc, MIRIENS_2ND_SIGIL, SYMBOL_OF_JUREK)
        take_items(pc, MIRIENS_2ND_SIGIL, 1)
        give_items(pc, MIRIENS_3RD_SIGIL, 1)
        take_items(pc, SYMBOL_OF_JUREK, 1)
        qs.set_cond(19, true)
        html = event
      end
    when "30070-02.html"
      give_items(pc, HIGH_PRIESTS_SIGIL, 1)
      give_items(pc, SYLVAINS_LETTER, 1)
      qs.set_cond(2, true)
      html = event
    when "30071-04.html"
      if has_quest_items?(pc, CRERAS_PAINTING2)
        take_items(pc, CRERAS_PAINTING2, 1)
        give_items(pc, CRERAS_PAINTING3, 1)
        qs.set_cond(10, true)
        html = event
      end
    when "30103-04.html"
      give_items(pc, VALKONS_REQUEST, 1)
      html = event
    when "30111-05.html"
      if has_quest_items?(pc, CRONOS_LETTER)
        take_items(pc, CRONOS_LETTER, 1)
        give_items(pc, DIETERS_KEY, 1)
        qs.set_cond(21, true)
        html = event
      end
    when "30111-09.html"
      if has_quest_items?(pc, CRETAS_2ND_LETTER)
        take_items(pc, CRETAS_2ND_LETTER, 1)
        give_items(pc, DIETERS_LETTER, 1)
        give_items(pc, DIETERS_DIARY, 1)
        qs.set_cond(23, true)
        html = event
      end
    when "30115-03.html"
      give_items(pc, JUREKS_LIST, 1)
      give_items(pc, GRAND_MAGISTER_SIGIL, 1)
      qs.set_cond(16, true)
      html = event
    when "30230-02.html"
      if has_quest_items?(pc, DIETERS_LETTER)
        take_items(pc, DIETERS_LETTER, 1)
        give_items(pc, RAUTS_LETTER_ENVELOPE, 1)
        qs.set_cond(24, true)
        html = event
      end
    when "30316-02.html"
      if has_quest_items?(pc, RAUTS_LETTER_ENVELOPE)
        take_items(pc, RAUTS_LETTER_ENVELOPE, 1)
        give_items(pc, SCRIPTURE_CHAPTER_1, 1)
        give_items(pc, STRONG_LIGUOR, 1)
        qs.set_cond(25, true)
        html = event
      end
    when "30608-02.html"
      if has_quest_items?(pc, SYLVAINS_LETTER)
        give_items(pc, MARIAS_1ST_LETTER, 1)
        take_items(pc, SYLVAINS_LETTER, 1)
        qs.set_cond(3, true)
        html = event
      end
    when "30608-08.html"
      if has_quest_items?(pc, CRETAS_1ST_LETTER)
        give_items(pc, LUCILLAS_HANDBAG, 1)
        take_items(pc, CRETAS_1ST_LETTER, 1)
        qs.set_cond(7, true)
        html = event
      end
    when "30608-14.html"
      if has_quest_items?(pc, CRERAS_PAINTING3)
        take_items(pc, CRERAS_PAINTING3, 1)
        take_items(pc, BROWN_SCROLL_SCRAP, -1)
        give_items(pc, CRYSTAL_OF_PURITY1, 1)
        qs.set_cond(13, true)
        html = event
      end
    when "30609-05.html"
      if has_quest_items?(pc, MARIAS_2ND_LETTER)
        take_items(pc, MARIAS_2ND_LETTER, 1)
        give_items(pc, CRETAS_1ST_LETTER, 1)
        qs.set_cond(6, true)
        html = event
      end
    when "30609-09.html"
      if has_quest_items?(pc, LUCILLAS_HANDBAG)
        take_items(pc, LUCILLAS_HANDBAG, 1)
        give_items(pc, CRERAS_PAINTING1, 1)
        qs.set_cond(8, true)
        html = event
      end
    when "30609-14.html"
      if has_quest_items?(pc, DIETERS_KEY)
        take_items(pc, DIETERS_KEY, 1)
        give_items(pc, CRETAS_2ND_LETTER, 1)
        qs.set_cond(22, true)
        html = event
      end
    when "30610-10.html"
      give_items(pc, CRONOS_SIGIL, 1)
      give_items(pc, CRONOS_LETTER, 1)
      qs.set_cond(20, true)
      html = event
    when "30610-14.html"
      if has_quest_items?(pc, SCRIPTURE_CHAPTER_1, SCRIPTURE_CHAPTER_2, SCRIPTURE_CHAPTER_3, SCRIPTURE_CHAPTER_4)
        take_items(pc, CRONOS_SIGIL, 1)
        take_items(pc, DIETERS_DIARY, 1)
        take_items(pc, TRIFFS_RING, 1)
        take_items(pc, SCRIPTURE_CHAPTER_1, 1)
        take_items(pc, SCRIPTURE_CHAPTER_2, 1)
        take_items(pc, SCRIPTURE_CHAPTER_3, 1)
        take_items(pc, SCRIPTURE_CHAPTER_4, 1)
        give_items(pc, SYMBOL_OF_CRONOS, 1)
        qs.set_cond(31, true)
        html = event
      end
    when "30611-04.html"
      if has_quest_items?(pc, STRONG_LIGUOR)
        give_items(pc, TRIFFS_RING, 1)
        take_items(pc, STRONG_LIGUOR, 1)
        qs.set_cond(26, true)
        html = event
      end
    when "30612-04.html"
      give_items(pc, CASIANS_LIST, 1)
      qs.set_cond(28, true)
      html = event
    when "30612-07.html"
      give_items(pc, SCRIPTURE_CHAPTER_4, 1)
      take_items(pc, POITANS_NOTES, 1)
      take_items(pc, CASIANS_LIST, 1)
      take_items(pc, GHOULS_SKIN, -1)
      take_items(pc, MEDUSAS_BLOOD, -1)
      take_items(pc, FETTERED_SOULS_ICHOR, -1)
      take_items(pc, ENCHANTED_GARGOYLES_NAIL, -1)
      qs.set_cond(30, true)
      html = event
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when MONSTER_EYE_DESTROYER
        if has_quest_items?(killer, MIRIENS_2ND_SIGIL, GRAND_MAGISTER_SIGIL, JUREKS_LIST) && get_quest_items_count(killer, MONSTER_EYE_DESTROYER_SKIN) < 5
          give_items(killer, MONSTER_EYE_DESTROYER_SKIN, 1)
          if get_quest_items_count(killer, MONSTER_EYE_DESTROYER_SKIN) == 5 && get_quest_items_count(killer, SHAMANS_NECKLACE) >= 5 && get_quest_items_count(killer, SHACKLES_SCALP) >= 2
            qs.set_cond(17, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when MEDUSA
        if has_quest_items?(killer, TRIFFS_RING, POITANS_NOTES, CASIANS_LIST) && get_quest_items_count(killer, MEDUSAS_BLOOD) < 12
          give_items(killer, MEDUSAS_BLOOD, 1)
          if get_quest_items_count(killer, MEDUSAS_BLOOD) == 12
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when GHOUL
        if has_quest_items?(killer, TRIFFS_RING, POITANS_NOTES, CASIANS_LIST) && get_quest_items_count(killer, GHOULS_SKIN) < 10
          give_items(killer, GHOULS_SKIN, 1)
          if get_quest_items_count(killer, GHOULS_SKIN) == 10
            qs.set_cond(29, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when SHACKLE1, SHACKLE2
        if has_quest_items?(killer, MIRIENS_2ND_SIGIL, GRAND_MAGISTER_SIGIL, JUREKS_LIST) && get_quest_items_count(killer, SHACKLES_SCALP) < 2
          give_items(killer, SHACKLES_SCALP, 1)
          if get_quest_items_count(killer, MONSTER_EYE_DESTROYER_SKIN) >= 5 && get_quest_items_count(killer, SHAMANS_NECKLACE) >= 5 && get_quest_items_count(killer, SHACKLES_SCALP) == 2
            qs.set_cond(17, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when BREKA_ORC_SHAMAN
        if has_quest_items?(killer, MIRIENS_2ND_SIGIL, GRAND_MAGISTER_SIGIL, JUREKS_LIST) && get_quest_items_count(killer, SHAMANS_NECKLACE) < 5
          give_items(killer, SHAMANS_NECKLACE, 1)
          if get_quest_items_count(killer, MONSTER_EYE_DESTROYER_SKIN) >= 5 && get_quest_items_count(killer, SHAMANS_NECKLACE) == 5 && get_quest_items_count(killer, SHACKLES_SCALP) >= 2
            qs.set_cond(17, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when FETTERED_SOUL
        if has_quest_items?(killer, TRIFFS_RING, POITANS_NOTES, CASIANS_LIST) && get_quest_items_count(killer, FETTERED_SOULS_ICHOR) < 5
          give_items(killer, FETTERED_SOULS_ICHOR, 1)
          if get_quest_items_count(killer, FETTERED_SOULS_ICHOR) >= 5
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when GRANDIS
        if has_quest_items?(killer, MIRIENS_3RD_SIGIL, CRONOS_SIGIL, TRIFFS_RING) && !has_quest_items?(killer, SCRIPTURE_CHAPTER_3)
          give_items(killer, SCRIPTURE_CHAPTER_3, 1)
          play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
        end
      when ENCHANTED_GARGOYLE
        if has_quest_items?(killer, TRIFFS_RING, POITANS_NOTES, CASIANS_LIST) && get_quest_items_count(killer, ENCHANTED_GARGOYLES_NAIL) < 5
          give_items(killer, ENCHANTED_GARGOYLES_NAIL, 1)
          if get_quest_items_count(killer, ENCHANTED_GARGOYLES_NAIL) >= 5
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      when LETO_LIZARDMAN_WARRIOR
        if has_quest_items?(killer, MIRIENS_1ST_SIGIL, HIGH_PRIESTS_SIGIL, CRERAS_PAINTING3) && get_quest_items_count(killer, BROWN_SCROLL_SCRAP) < 5
          give_items(killer, BROWN_SCROLL_SCRAP, 1)
          if get_quest_items_count(killer, BROWN_SCROLL_SCRAP) == 5
            qs.set_cond(12, true)
          else
            play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == MAGISTER_MIRIEN
        if pc.class_id.wizard? || pc.class_id.elven_wizard? || pc.class_id.dark_wizard?
          if pc.level < MIN_LVL
            html = "30461-02.html"
          else
            html = "30461-03.htm"
          end
        else
          html = "30461-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when MAGISTER_MIRIEN
        if has_quest_items?(pc, MIRIENS_1ST_SIGIL)
          if !has_quest_items?(pc, SYMBOL_OF_SYLVAIN)
            html = "30461-05.html"
          else
            take_items(pc, MIRIENS_1ST_SIGIL, 1)
            give_items(pc, MIRIENS_2ND_SIGIL, 1)
            take_items(pc, SYMBOL_OF_SYLVAIN, 1)
            qs.set_cond(15, true)
            html = "30461-06.html"
          end
        elsif has_quest_items?(pc, MIRIENS_2ND_SIGIL)
          if !has_quest_items?(pc, SYMBOL_OF_JUREK)
            html = "30461-07.html"
          else
            html = "30461-08.html"
          end
        elsif has_quest_items?(pc, MIRIENS_INSTRUCTION)
          if pc.level < LEVEL
            html = "30461-11.html"
          else
            take_items(pc, MIRIENS_INSTRUCTION, 1)
            give_items(pc, MIRIENS_3RD_SIGIL, 1)
            qs.set_cond(19, true)
            html = "30461-12.html"
          end
        elsif has_quest_items?(pc, MIRIENS_3RD_SIGIL)
          if !has_quest_items?(pc, SYMBOL_OF_CRONOS)
            html = "30461-13.html"
          else
            give_adena(pc, 319_628, true)
            give_items(pc, MARK_OF_SCHOLAR, 1)
            add_exp_and_sp(pc, 1_753_926, 113_754)
            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            html = "30461-14.html"
          end
        end
      when HIGH_PRIEST_SYLVAIN
        if has_quest_items?(pc, MIRIENS_1ST_SIGIL) && !has_at_least_one_quest_item?(pc, HIGH_PRIESTS_SIGIL, SYMBOL_OF_SYLVAIN)
          html = "30070-01.html"
        elsif !has_quest_items?(pc, CRYSTAL_OF_PURITY1) && has_quest_items?(pc, HIGH_PRIESTS_SIGIL, MIRIENS_1ST_SIGIL)
          html = "30070-03.html"
        elsif has_quest_items?(pc, HIGH_PRIESTS_SIGIL, MIRIENS_1ST_SIGIL, CRYSTAL_OF_PURITY1)
          take_items(pc, CRYSTAL_OF_PURITY1, 1)
          take_items(pc, HIGH_PRIESTS_SIGIL, 1)
          give_items(pc, SYMBOL_OF_SYLVAIN, 1)
          qs.set_cond(14, true)
          html = "30070-04.html"
        elsif has_quest_items?(pc, MIRIENS_1ST_SIGIL, SYMBOL_OF_SYLVAIN) && !has_quest_items?(pc, HIGH_PRIESTS_SIGIL)
          html = "30070-05.html"
        elsif has_at_least_one_quest_item?(pc, MIRIENS_2ND_SIGIL, MIRIENS_3RD_SIGIL)
          html = "30070-06.html"
        end
      when CAPTAIN_LUCAS
        if has_quest_items?(pc, MIRIENS_1ST_SIGIL, HIGH_PRIESTS_SIGIL)
          if has_quest_items?(pc, MARIAS_1ST_LETTER)
            take_items(pc, MARIAS_1ST_LETTER, 1)
            give_items(pc, LUCASS_LETTER, 1)
            qs.set_cond(4, true)
            html = "30071-01.html"
          elsif has_at_least_one_quest_item?(pc, MARIAS_2ND_LETTER, CRETAS_1ST_LETTER, LUCILLAS_HANDBAG, CRERAS_PAINTING1, LUCASS_LETTER)
            html = "30071-02.html"
          elsif has_quest_items?(pc, CRERAS_PAINTING2)
            html = "30071-03.html"
          elsif has_quest_items?(pc, CRERAS_PAINTING3)
            if get_quest_items_count(pc, BROWN_SCROLL_SCRAP) < 5
              html = "30071-05.html"
            else
              html = "30071-06.html"
            end
          end
        elsif has_at_least_one_quest_item?(pc, SYMBOL_OF_SYLVAIN, MIRIENS_2ND_SIGIL, MIRIENS_3RD_SIGIL, CRYSTAL_OF_PURITY1)
          html = "30071-07.html"
        end
      when WAREHOUSE_KEEPER_VALKON
        if has_quest_items?(pc, TRIFFS_RING)
          if !has_at_least_one_quest_item?(pc, VALKONS_REQUEST, CRYSTAL_OF_PURITY2, SCRIPTURE_CHAPTER_2)
            html = "30103-01.html"
          elsif has_quest_items?(pc, VALKONS_REQUEST) && !has_at_least_one_quest_item?(pc, CRYSTAL_OF_PURITY2, SCRIPTURE_CHAPTER_2)
            html = "30103-05.html"
          elsif has_quest_items?(pc, CRYSTAL_OF_PURITY2) && !has_at_least_one_quest_item?(pc, VALKONS_REQUEST, SCRIPTURE_CHAPTER_2)
            give_items(pc, SCRIPTURE_CHAPTER_2, 1)
            take_items(pc, CRYSTAL_OF_PURITY2, 1)
            html = "30103-06.html"
          elsif has_quest_items?(pc, SCRIPTURE_CHAPTER_2) && !has_at_least_one_quest_item?(pc, VALKONS_REQUEST, CRYSTAL_OF_PURITY2)
            html = "30103-07.html"
          end
        end
      when MAGISTER_DIETER
        if has_quest_items?(pc, MIRIENS_3RD_SIGIL, CRONOS_SIGIL)
          if has_quest_items?(pc, CRONOS_LETTER)
            html = "30111-01.html"
          elsif has_quest_items?(pc, DIETERS_KEY)
            html = "30111-06.html"
          elsif has_quest_items?(pc, CRETAS_2ND_LETTER)
            html = "30111-07.html"
          elsif has_quest_items?(pc, DIETERS_DIARY, DIETERS_LETTER)
            html = "30111-10.html"
          elsif has_quest_items?(pc, DIETERS_DIARY, RAUTS_LETTER_ENVELOPE)
            html = "30111-11.html"
          elsif has_quest_items?(pc, DIETERS_DIARY) && !has_at_least_one_quest_item?(pc, DIETERS_LETTER, RAUTS_LETTER_ENVELOPE)
            if has_quest_items?(pc, SCRIPTURE_CHAPTER_1, SCRIPTURE_CHAPTER_2, SCRIPTURE_CHAPTER_3, SCRIPTURE_CHAPTER_4)
              html = "30111-13.html"
            else
              html = "30111-12.html"
            end
          end
        elsif has_quest_items?(pc, SYMBOL_OF_CRONOS)
          html = "30111-15.html"
        end
      when GRAND_MAGISTER_JUREK
        if has_quest_items?(pc, MIRIENS_2ND_SIGIL)
          if !has_at_least_one_quest_item?(pc, GRAND_MAGISTER_SIGIL, SYMBOL_OF_JUREK)
            html = "30115-01.html"
          elsif has_quest_items?(pc, JUREKS_LIST)
            if get_quest_items_count(pc, MONSTER_EYE_DESTROYER_SKIN) &+ get_quest_items_count(pc, SHAMANS_NECKLACE) &+ get_quest_items_count(pc, SHACKLES_SCALP) < 12
              html = "30115-04.html"
            else
              take_items(pc, GRAND_MAGISTER_SIGIL, 1)
              take_items(pc, JUREKS_LIST, 1)
              take_items(pc, MONSTER_EYE_DESTROYER_SKIN, -1)
              take_items(pc, SHAMANS_NECKLACE, -1)
              take_items(pc, SHACKLES_SCALP, -1)
              give_items(pc, SYMBOL_OF_JUREK, 1)
              qs.set_cond(18, true)
              html = "30115-05.html"
            end
          elsif has_quest_items?(pc, SYMBOL_OF_JUREK) && !has_quest_items?(pc, GRAND_MAGISTER_SIGIL)
            html = "30115-06.html"
          end
        elsif has_at_least_one_quest_item?(pc, MIRIENS_1ST_SIGIL, MIRIENS_3RD_SIGIL)
          html = "30115-07.html"
        end
      when TRADER_EDROC
        if has_quest_items?(pc, DIETERS_DIARY)
          if has_quest_items?(pc, DIETERS_LETTER)
            html = "30230-01.html"
          elsif has_quest_items?(pc, RAUTS_LETTER_ENVELOPE)
            html = "30230-03.html"
          elsif has_at_least_one_quest_item?(pc, STRONG_LIGUOR, TRIFFS_RING)
            html = "30230-04.html"
          end
        end
      when WAREHOUSE_KEEPER_RAUT
        if has_quest_items?(pc, DIETERS_DIARY)
          if has_quest_items?(pc, RAUTS_LETTER_ENVELOPE)
            html = "30316-01.html"
          elsif has_quest_items?(pc, SCRIPTURE_CHAPTER_1, STRONG_LIGUOR)
            html = "30316-04.html"
          elsif has_quest_items?(pc, SCRIPTURE_CHAPTER_1, TRIFFS_RING)
            html = "30316-05.html"
          end
        end
      when BLACKSMITH_POITAN
        if has_quest_items?(pc, TRIFFS_RING)
          if !has_at_least_one_quest_item?(pc, POITANS_NOTES, CASIANS_LIST, SCRIPTURE_CHAPTER_4)
            give_items(pc, POITANS_NOTES, 1)
            html = "30458-01.html"
          elsif has_quest_items?(pc, POITANS_NOTES) && !has_at_least_one_quest_item?(pc, CASIANS_LIST, SCRIPTURE_CHAPTER_4)
            html = "30458-02.html"
          elsif has_quest_items?(pc, POITANS_NOTES, CASIANS_LIST) && !has_quest_items?(pc, SCRIPTURE_CHAPTER_4)
            html = "30458-03.html"
          elsif has_quest_items?(pc, SCRIPTURE_CHAPTER_4) && !has_at_least_one_quest_item?(pc, POITANS_NOTES, CASIANS_LIST)
            html = "30458-04.html"
          end
        end
      when MARIA
        if has_quest_items?(pc, MIRIENS_1ST_SIGIL, HIGH_PRIESTS_SIGIL)
          if has_quest_items?(pc, SYLVAINS_LETTER)
            html = "30608-01.html"
          elsif has_quest_items?(pc, MARIAS_1ST_LETTER)
            html = "30608-03.html"
          elsif has_quest_items?(pc, LUCASS_LETTER)
            give_items(pc, MARIAS_2ND_LETTER, 1)
            take_items(pc, LUCASS_LETTER, 1)
            qs.set_cond(5, true)
            html = "30608-04.html"
          elsif has_quest_items?(pc, MARIAS_2ND_LETTER)
            html = "30608-05.html"
          elsif has_quest_items?(pc, CRETAS_1ST_LETTER)
            html = "30608-06.html"
          elsif has_quest_items?(pc, LUCILLAS_HANDBAG)
            html = "30608-09.html"
          elsif has_quest_items?(pc, CRERAS_PAINTING1)
            take_items(pc, CRERAS_PAINTING1, 1)
            give_items(pc, CRERAS_PAINTING2, 1)
            qs.set_cond(9, true)
            html = "30608-10.html"
          elsif has_quest_items?(pc, CRERAS_PAINTING2)
            html = "30608-11.html"
          elsif has_quest_items?(pc, CRERAS_PAINTING3)
            if get_quest_items_count(pc, BROWN_SCROLL_SCRAP) < 5
              qs.set_cond(11, true)
              html = "30608-12.html"
            else
              html = "30608-13.html"
            end
          elsif has_quest_items?(pc, CRYSTAL_OF_PURITY1)
            html = "30608-15.html"
          end
        elsif has_at_least_one_quest_item?(pc, SYMBOL_OF_SYLVAIN, MIRIENS_2ND_SIGIL)
          html = "30608-16.html"
        elsif has_quest_items?(pc, MIRIENS_3RD_SIGIL)
          if !has_quest_items?(pc, VALKONS_REQUEST)
            html = "30608-17.html"
          else
            take_items(pc, VALKONS_REQUEST, 1)
            give_items(pc, CRYSTAL_OF_PURITY2, 1)
            html = "30608-18.html"
          end
        end
      when ASTROLOGER_CRETA
        if has_quest_items?(pc, MIRIENS_1ST_SIGIL, HIGH_PRIESTS_SIGIL)
          if has_quest_items?(pc, MARIAS_2ND_LETTER)
            html = "30609-01.html"
          elsif has_quest_items?(pc, CRETAS_1ST_LETTER)
            html = "30609-06.html"
          elsif has_quest_items?(pc, LUCILLAS_HANDBAG)
            html = "30609-07.html"
          elsif has_at_least_one_quest_item?(pc, CRERAS_PAINTING1, CRERAS_PAINTING2, CRERAS_PAINTING3)
            html = "30609-10.html"
          end
        elsif has_at_least_one_quest_item?(pc, CRYSTAL_OF_PURITY1, SYMBOL_OF_SYLVAIN, MIRIENS_2ND_SIGIL)
          html = "30609-11.html"
        elsif has_quest_items?(pc, MIRIENS_3RD_SIGIL)
          if has_quest_items?(pc, DIETERS_KEY)
            html = "30609-12.html"
          else
            html = "30609-15.html"
          end
        end
      when ELDER_CRONOS
        if has_quest_items?(pc, MIRIENS_3RD_SIGIL)
          if !has_at_least_one_quest_item?(pc, CRONOS_SIGIL, SYMBOL_OF_CRONOS)
            html = "30610-01.html"
          elsif has_quest_items?(pc, CRONOS_SIGIL)
            if has_quest_items?(pc, SCRIPTURE_CHAPTER_1, SCRIPTURE_CHAPTER_2, SCRIPTURE_CHAPTER_3, SCRIPTURE_CHAPTER_4)
              html = "30610-12.html"
            else
              html = "30610-11.html"
            end
          elsif has_quest_items?(pc, SYMBOL_OF_CRONOS) && !has_quest_items?(pc, CRONOS_SIGIL)
            html = "30610-15.html"
          end
        end
      when DRUNKARD_TRIFF
        if has_quest_items?(pc, DIETERS_DIARY, SCRIPTURE_CHAPTER_1, STRONG_LIGUOR)
          html = "30611-01.html"
        elsif has_at_least_one_quest_item?(pc, TRIFFS_RING, SYMBOL_OF_CRONOS)
          html = "30611-05.html"
        end
      when ELDER_CASIAN
        if has_quest_items?(pc, TRIFFS_RING, POITANS_NOTES)
          if !has_quest_items?(pc, CASIANS_LIST)
            if has_quest_items?(pc, SCRIPTURE_CHAPTER_1, SCRIPTURE_CHAPTER_2, SCRIPTURE_CHAPTER_3)
              html = "30612-02.html"
            else
              html = "30612-01.html"
            end
          else
            if get_quest_items_count(pc, GHOULS_SKIN) &+ get_quest_items_count(pc, MEDUSAS_BLOOD) &+ get_quest_items_count(pc, FETTERED_SOULS_ICHOR) &+ get_quest_items_count(pc, ENCHANTED_GARGOYLES_NAIL) < 32
              html = "30612-05.html"
            else
              html = "30612-06.html"
            end
          end
        elsif has_quest_items?(pc, TRIFFS_RING, SCRIPTURE_CHAPTER_1, SCRIPTURE_CHAPTER_2, SCRIPTURE_CHAPTER_3, SCRIPTURE_CHAPTER_4) && !has_at_least_one_quest_item?(pc, POITANS_NOTES, CASIANS_LIST)
          html = "30612-08.html"
        end
      end
    elsif qs.completed?
      if npc.id == MAGISTER_MIRIEN
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
