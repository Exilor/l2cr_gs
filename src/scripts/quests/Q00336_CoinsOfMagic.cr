class Scripts::Q00336_CoinsOfMagic < Quest
  # NPCs
  private PANO = 30078
  private COLLOB = 30092
  private RAPIN = 30165
  private HAGGER = 30183
  private STAN = 30200
  private WAREHOUSE_KEEPER_SORINT = 30232
  private RESEARCHER_LORAIN = 30673
  private BLACKSMITH_DUNING = 30688
  private MAGISTER_PAGE = 30696
  private UNION_PRESIDENT_BERNARD = 30702
  private HEAD_BLACKSMITH_FERRIS = 30847
  # Items
  private Q_BLOOD_MEDUSA = 3472
  private Q_BLOOD_WEREWOLF = 3473
  private Q_BLOOD_BASILISK = 3474
  private Q_BLOOD_DREVANUL = 3475
  private Q_BLOOD_SUCCUBUS = 3476
  private Q_BLOOD_DRAGON = 3477
  private Q_BERETHS_BLOOD_DRAGON = 3478
  private Q_MANAKS_BLOOD_WEREWOLF = 3479
  private Q_NIAS_BLOOD_MEDUSA = 3480
  private Q_GOLD_DRAGON = 3481
  private Q_GOLD_WYVERN = 3482
  private Q_GOLD_KNIGHT = 3483
  private Q_GOLD_GIANT = 3484
  private Q_GOLD_DRAKE = 3485
  private Q_GOLD_WYRM = 3486
  private Q_BERETHS_GOLD_DRAGON = 3487
  private Q_MANAKS_GOLD_GIANT = 3488
  private Q_NIAS_GOLD_WYVERN = 3489
  private Q_SILVER_UNICORN = 3490
  private Q_SILVER_FAIRY = 3491
  private Q_SILVER_DRYAD = 3492
  private Q_SILVER_DRAGON = 3493
  private Q_SILVER_GOLEM = 3494
  private Q_SILVER_UNDINE = 3495
  private Q_BERETHS_SILVER_DRAGON = 3496
  private Q_MANAKS_SILVER_DRYAD = 3497
  private Q_NIAS_SILVER_FAIRY = 3498
  private Q_COIN_DIAGRAM = 3811
  private Q_KALDIS_GOLD_DRAGON = 3812
  private Q_CC_MEMBERSHIP_1 = 3813
  private Q_CC_MEMBERSHIP_2 = 3814
  private Q_CC_MEMBERSHIP_3 = 3815
  # Monsters
  private HEADLESS_KNIGHT = 20146
  private OEL_MAHUM = 20161
  private SHACKLE = 20235
  private ROYAL_CAVE_SERVANT = 20240
  private MALRUK_SUCCUBUS_TUREN = 20245
  private ROYAL_CAVE_SERVANT_HOLD = 20276
  private SHACKLE_HOLD = 20279
  private HEADLESS_KNIGHT_HOLD = 20280
  private H_MALRUK_SUCCUBUS_TUREN = 20284
  private BYFOOT = 20568
  private BYFOOT_SIGEL = 20569
  private TARLK_BUGBEAR_BOSS = 20572
  private OEL_MAHUM_WARRIOR = 20575
  private OEL_MAHUM_WITCH_DOCTOR = 20576
  private TIMAK_ORC = 20583
  private TIMAK_ORC_ARCHER = 20584
  private TIMAK_ORC_SOLDIER = 20585
  private TIMAK_ORC_SHAMAN = 20587
  private LAKIN = 20604
  private HARIT_LIZARDMAN_SHAMAN = 20644
  private HARIT_LIZARDM_MATRIARCH = 20645
  private HATAR_HANISHEE = 20663
  private DOOM_KNIGHT = 20674
  private PUNISHMENT_OF_UNDEAD = 20678
  private VANOR_SILENOS_SHAMAN = 20685
  private HUNGRY_CORPSE = 20954
  private NIHIL_INVADER = 20957
  private DARK_GUARD = 20959
  private BLOODY_GHOST = 20960
  private FLOAT_OF_GRAVE = 21003
  private DOOM_SERVANT = 21006
  private DOOM_ARCHER = 21008
  private KUKABURO = 21274
  private KUKABURO_A = 21275
  private KUKABURO_B = 21276
  private ANTELOPE = 21278
  private ANTELOPE_A = 21279
  private ANTELOPE_B = 21280
  private BANDERSNATCH = 21282
  private BANDERSNATCH_A = 21283
  private BANDERSNATCH_B = 21284
  private BUFFALO = 21286
  private BUFFALO_A = 21287
  private BUFFALO_B = 21288
  private BRILLIANT_CLAW = 21521
  private BRILLIANT_CLAW_1 = 21522
  private BRILLIANT_WISDOM = 21526
  private BRILLIANT_VENGEANCE = 21531
  private BRILLIANT_VENGEANCE_1 = 21658
  private BRILLIANT_ANGUISH = 21539
  private BRILLIANT_ANGUISH_1 = 21540
  # Rewards
  private DEMON_STAFF = 206
  private DARK_SCREAMER = 233
  private WIDOW_MAKER = 303
  private SWORD_OF_LIMIT = 132
  private DEMONS_BOOTS = 2435
  private DEMONS_HOSE = 472
  private DEMONS_GLOVES = 2459
  private FULL_PLATE_HELMET = 2414
  private MOONSTONE_EARING = 852
  private NASSENS_EARING = 855
  private RING_OF_BINDING = 886
  private NECKLACE_OF_PROTECTION = 916
  # Variables name
  private WEIGHT_POINT = "weight_point"
  private PARAM_1 = "param1"
  private PARAM_2 = "param2"
  private PARAM_3 = "param3"
  private FLAG = "flag"

  def initialize
    super(336, self.class.simple_name, "Coins of Magic")

    add_start_npc(WAREHOUSE_KEEPER_SORINT)
    add_talk_id(
      PANO, COLLOB, RAPIN, HAGGER, STAN, RESEARCHER_LORAIN, BLACKSMITH_DUNING,
      MAGISTER_PAGE, UNION_PRESIDENT_BERNARD, HEAD_BLACKSMITH_FERRIS
    )
    add_kill_id(
      HEADLESS_KNIGHT, OEL_MAHUM, SHACKLE, ROYAL_CAVE_SERVANT,
      MALRUK_SUCCUBUS_TUREN, ROYAL_CAVE_SERVANT_HOLD, SHACKLE_HOLD,
      HEADLESS_KNIGHT_HOLD, H_MALRUK_SUCCUBUS_TUREN, BYFOOT, BYFOOT_SIGEL,
      TARLK_BUGBEAR_BOSS, OEL_MAHUM_WARRIOR, OEL_MAHUM_WITCH_DOCTOR,
      TIMAK_ORC, TIMAK_ORC_ARCHER, TIMAK_ORC_SOLDIER, TIMAK_ORC_SHAMAN,
      LAKIN, HARIT_LIZARDMAN_SHAMAN, HARIT_LIZARDM_MATRIARCH, HATAR_HANISHEE,
      DOOM_KNIGHT, PUNISHMENT_OF_UNDEAD, VANOR_SILENOS_SHAMAN, HUNGRY_CORPSE,
      NIHIL_INVADER, DARK_GUARD, BLOODY_GHOST, FLOAT_OF_GRAVE, DOOM_SERVANT,
      DOOM_ARCHER, KUKABURO, KUKABURO_A, KUKABURO_B, ANTELOPE, ANTELOPE_A,
      ANTELOPE_B, BANDERSNATCH, BANDERSNATCH_A, BANDERSNATCH_B, BUFFALO,
      BUFFALO_A, BUFFALO_B, BRILLIANT_CLAW, BRILLIANT_CLAW_1,
      BRILLIANT_WISDOM, BRILLIANT_VENGEANCE, BRILLIANT_VENGEANCE_1,
      BRILLIANT_ANGUISH, BRILLIANT_ANGUISH_1
    )
    register_quest_items(
      Q_COIN_DIAGRAM, Q_KALDIS_GOLD_DRAGON, Q_CC_MEMBERSHIP_1,
      Q_CC_MEMBERSHIP_2, Q_CC_MEMBERSHIP_3
    )
  end

  def on_talk(npc, pc)
    unless qs = get_quest_state(pc, true)
      return get_no_quest_msg(pc)
    end

    case npc.id
    when PANO, COLLOB, HEAD_BLACKSMITH_FERRIS
      if qs.has_quest_items?(Q_CC_MEMBERSHIP_1)
        reset_params(qs)
        return "#{npc.id}-01.html"
      end
      if qs.has_quest_items?(Q_CC_MEMBERSHIP_2) || qs.has_quest_items?(Q_CC_MEMBERSHIP_3)
        return "#{npc.id}-54.html"
      end
    when RAPIN, STAN, BLACKSMITH_DUNING
      if qs.has_quest_items?(Q_CC_MEMBERSHIP_1) || qs.has_quest_items?(Q_CC_MEMBERSHIP_2)
        reset_params(qs)
        return "#{npc.id}-01.html"
      end
      if qs.has_quest_items?(Q_CC_MEMBERSHIP_3)
        return "#{npc.id}-54.html"
      end
    when HAGGER, MAGISTER_PAGE, RESEARCHER_LORAIN
      if qs.has_quest_items?(Q_CC_MEMBERSHIP_1) || qs.has_quest_items?(Q_CC_MEMBERSHIP_2) || qs.has_quest_items?(Q_CC_MEMBERSHIP_3)
        reset_params(qs)
        return "#{npc.id}-01.html"
      end
    when UNION_PRESIDENT_BERNARD
      if qs.memo_state == 1 && qs.has_quest_items?(Q_COIN_DIAGRAM)
        return "30702-01.html"
      end
      if qs.memo_state >= 3
        return "30702-05.html"
      end
      if qs.memo_state == 2
        return "30702-02a.html"
      end
    when WAREHOUSE_KEEPER_SORINT
      if qs.created?
        if pc.level < 40
          return "30232-01.htm"
        end
        return "30232-02.htm"
      end
      if qs.started?
        if !qs.has_quest_items?(Q_KALDIS_GOLD_DRAGON) && (qs.memo_state == 1 || qs.memo_state == 2)
          return "30232-06.html"
        end
        if qs.has_quest_items?(Q_KALDIS_GOLD_DRAGON) && (qs.memo_state == 1 || qs.memo_state == 2)
          qs.give_items(Q_CC_MEMBERSHIP_3, 1)
          qs.take_items(Q_COIN_DIAGRAM, -1)
          qs.take_items(Q_KALDIS_GOLD_DRAGON, 1)
          qs.memo_state = 3
          qs.set_cond(4)
          qs.show_question_mark(336)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-07.html"
        end
        if qs.has_quest_items?(Q_CC_MEMBERSHIP_3) && qs.memo_state == 3
          return "30232-10.html"
        end
        if qs.has_quest_items?(Q_CC_MEMBERSHIP_2) && qs.memo_state == 3
          return "30232-11.html"
        end
        if qs.has_quest_items?(Q_CC_MEMBERSHIP_1) && qs.memo_state == 3
          return "30232-12.html"
        end
      end
    end

    get_no_quest_msg(pc)
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    html = nil

    if "QUEST_ACCEPTED" == event
      qs.play_sound(Sound::ITEMSOUND_QUEST_ACCEPT)
      unless qs.has_quest_items?(Q_COIN_DIAGRAM)
        qs.give_items(Q_COIN_DIAGRAM, 1)
      end
      qs.memo_state = 1
      qs.start_quest
      qs.show_question_mark(336)
      qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
      return "30232-05.htm"
    end
    if event.includes?(".htm")
      return event
    end
    return unless npc
    npc_id = npc.id
    event_id = event.to_i

    case npc_id
    when PANO, COLLOB, RAPIN, HAGGER, STAN, RESEARCHER_LORAIN,
         BLACKSMITH_DUNING, MAGISTER_PAGE, HEAD_BLACKSMITH_FERRIS
      case event_id
      when 1
        qs.set(PARAM_2, 11)
        return "#{npc_id}-02.html"
      when 2
        qs.set(PARAM_2, 21)
        return "#{npc_id}-03.html"
      when 3
        qs.set(PARAM_2, 31)
        return "#{npc_id}-04.html"
      when 4
        qs.set(PARAM_2, 42)
        return "#{npc_id}-05.html"
      when 5
        return "#{npc_id}-06.html"
      when 9
        return "#{npc_id}-53.html"
      when 13
        if qs.get_int(FLAG) == 1
          qs.set(FLAG, 16)
          return "#{npc_id}-14.html"
        end
      when 14
        if qs.get_int(FLAG) == 1
          qs.set(FLAG, 32)
          return "#{npc_id}-15.html"
        end
      when 15
        if qs.get_int(FLAG) == 1
          qs.set(FLAG, 48)
          return "#{npc_id}-16.html"
        end
      when 16
        qs.set(FLAG, qs.get_int(FLAG) + 4)
        return "#{npc_id}-17.html"
      when 17
        qs.set(FLAG, qs.get_int(FLAG) + 8)
        return "#{npc_id}-18.html"
      when 18
        qs.set(FLAG, qs.get_int(FLAG) + 12)
        return "#{npc_id}-19.html"
      when 22
        return "#{npc_id}-01.html"
      end
    end

    case npc_id
    when PANO
      case event_id
      when 6
        return short_first_steps(qs, PANO, 1, 4, Q_SILVER_DRYAD, Q_SILVER_UNDINE, 1, Q_GOLD_GIANT, Q_SILVER_DRYAD, Q_BLOOD_BASILISK)
      when 7
        return short_first_steps(qs, PANO, 2, 8, Q_SILVER_DRYAD, Q_SILVER_UNDINE, 1, Q_GOLD_GIANT, Q_SILVER_DRYAD, Q_BLOOD_BASILISK)
      when 8
        return short_first_steps(qs, PANO, 3, 9, Q_SILVER_DRYAD, Q_SILVER_UNDINE, 1, Q_GOLD_GIANT, Q_SILVER_DRYAD, Q_BLOOD_BASILISK)
      when 10
        return short_second_step_two_items(qs, PANO, 1, Q_SILVER_DRYAD, Q_SILVER_UNDINE, Q_BERETHS_SILVER_DRAGON, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_GOLD_DRAGON, Q_SILVER_DRYAD, Q_SILVER_UNDINE, Q_SILVER_DRAGON, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_BLOOD_DRAGON)
      when 11
        return short_second_step_two_items(qs, PANO, 5, Q_SILVER_DRYAD, Q_SILVER_UNDINE, Q_BERETHS_SILVER_DRAGON, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_GOLD_DRAGON, Q_SILVER_DRYAD, Q_SILVER_UNDINE, Q_SILVER_DRAGON, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_BLOOD_DRAGON)
      when 12
        return short_second_step_two_items(qs, PANO, 10, Q_SILVER_DRYAD, Q_SILVER_UNDINE, Q_BERETHS_SILVER_DRAGON, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_GOLD_DRAGON, Q_SILVER_DRYAD, Q_SILVER_UNDINE, Q_SILVER_DRAGON, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_BLOOD_DRAGON)
      when 19
        return short_third_step(qs, PANO, 1, Q_BERETHS_SILVER_DRAGON, Q_GOLD_DRAGON, Q_SILVER_DRAGON, Q_SILVER_DRAGON)
      when 20
        return short_third_step(qs, PANO, 2, Q_BERETHS_SILVER_DRAGON, Q_GOLD_DRAGON, Q_SILVER_DRAGON, Q_SILVER_DRAGON)
      when 21
        return short_third_step(qs, PANO, 3, Q_BERETHS_SILVER_DRAGON, Q_GOLD_DRAGON, Q_SILVER_DRAGON, Q_SILVER_DRAGON)
      end
    when COLLOB
      case event_id
      when 6
        return short_first_steps(qs, COLLOB, 1, 4, Q_GOLD_WYRM, Q_GOLD_GIANT, 1, Q_GOLD_WYRM, Q_SILVER_UNDINE, Q_BLOOD_SUCCUBUS)
      when 7
        return short_first_steps(qs, COLLOB, 2, 8, Q_GOLD_WYRM, Q_GOLD_GIANT, 1, Q_GOLD_WYRM, Q_SILVER_UNDINE, Q_BLOOD_SUCCUBUS)
      when 8
        return short_first_steps(qs, COLLOB, 3, 9, Q_GOLD_WYRM, Q_GOLD_GIANT, 1, Q_GOLD_WYRM, Q_SILVER_UNDINE, Q_BLOOD_SUCCUBUS)
      when 10
        return short_second_step_two_items(qs, COLLOB, 1, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_BERETHS_GOLD_DRAGON, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_GOLD_DRAGON, Q_SILVER_DRYAD, Q_SILVER_UNDINE, Q_SILVER_DRAGON, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_BLOOD_DRAGON)
      when 11
        return short_second_step_two_items(qs, COLLOB, 5, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_BERETHS_GOLD_DRAGON, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_GOLD_DRAGON, Q_SILVER_DRYAD, Q_SILVER_UNDINE, Q_SILVER_DRAGON, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_BLOOD_DRAGON)
      when 12
        return short_second_step_two_items(qs, COLLOB, 10, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_BERETHS_GOLD_DRAGON, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_GOLD_DRAGON, Q_SILVER_DRYAD, Q_SILVER_UNDINE, Q_SILVER_DRAGON, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_BLOOD_DRAGON)
      when 19
        return short_third_step(qs, COLLOB, 1, Q_BERETHS_GOLD_DRAGON, Q_GOLD_DRAGON, Q_SILVER_DRAGON, Q_BLOOD_DRAGON)
      when 20
        return short_third_step(qs, COLLOB, 2, Q_BERETHS_GOLD_DRAGON, Q_GOLD_DRAGON, Q_SILVER_DRAGON, Q_BLOOD_DRAGON)
      when 21
        return short_third_step(qs, COLLOB, 3, Q_BERETHS_GOLD_DRAGON, Q_GOLD_DRAGON, Q_SILVER_DRAGON, Q_BLOOD_DRAGON)
      end
    when RAPIN
      case event_id
      when 6
        return short_first_steps(qs, RAPIN, 1, 3, Q_BLOOD_WEREWOLF, Q_BLOOD_DREVANUL, 1, Q_SILVER_GOLEM, Q_SILVER_FAIRY, Q_GOLD_DRAKE)
      when 7
        return short_first_steps(qs, RAPIN, 2, 7, Q_BLOOD_WEREWOLF, Q_BLOOD_DREVANUL, 1, Q_SILVER_GOLEM, Q_SILVER_FAIRY, Q_GOLD_DRAKE)
      when 8
        return short_first_steps(qs, RAPIN, 3, 9, Q_BLOOD_WEREWOLF, Q_BLOOD_DREVANUL, 1, Q_SILVER_GOLEM, Q_SILVER_FAIRY, Q_GOLD_DRAKE)
      when 10
        return short_second_step_two_items(qs, RAPIN, 1, Q_BLOOD_WEREWOLF, Q_BLOOD_DREVANUL, Q_MANAKS_BLOOD_WEREWOLF, Q_SILVER_GOLEM, Q_SILVER_FAIRY, Q_SILVER_UNDINE, Q_SILVER_GOLEM, Q_SILVER_FAIRY, Q_SILVER_DRYAD, Q_GOLD_DRAKE, Q_GOLD_KNIGHT, Q_GOLD_WYRM)
      when 11
        return short_second_step_two_items(qs, RAPIN, 5, Q_BLOOD_WEREWOLF, Q_BLOOD_DREVANUL, Q_MANAKS_BLOOD_WEREWOLF, Q_SILVER_GOLEM, Q_SILVER_FAIRY, Q_SILVER_UNDINE, Q_SILVER_GOLEM, Q_SILVER_FAIRY, Q_SILVER_DRYAD, Q_GOLD_DRAKE, Q_GOLD_KNIGHT, Q_GOLD_WYRM)
      when 12
        return short_second_step_two_items(qs, RAPIN, 10, Q_BLOOD_WEREWOLF, Q_BLOOD_DREVANUL, Q_MANAKS_BLOOD_WEREWOLF, Q_SILVER_GOLEM, Q_SILVER_FAIRY, Q_SILVER_UNDINE, Q_SILVER_GOLEM, Q_SILVER_FAIRY, Q_SILVER_DRYAD, Q_GOLD_DRAKE, Q_GOLD_KNIGHT, Q_GOLD_WYRM)
      when 19
        return short_third_step(qs, RAPIN, 1, Q_MANAKS_BLOOD_WEREWOLF, Q_SILVER_UNDINE, Q_SILVER_DRYAD, Q_GOLD_WYRM)
      when 20
        return short_third_step(qs, RAPIN, 2, Q_MANAKS_BLOOD_WEREWOLF, Q_SILVER_UNDINE, Q_SILVER_DRYAD, Q_GOLD_WYRM)
      when 21
        return short_third_step(qs, RAPIN, 3, Q_MANAKS_BLOOD_WEREWOLF, Q_SILVER_UNDINE, Q_SILVER_DRYAD, Q_GOLD_WYRM)
      end
    when HAGGER
      case event_id
      when 6
        return short_first_steps(qs, HAGGER, 1, 4, Q_SILVER_UNICORN, 0, 2, Q_BLOOD_MEDUSA, Q_SILVER_UNICORN, Q_GOLD_WYVERN)
      when 7
        return short_first_steps(qs, HAGGER, 2, 8, Q_SILVER_UNICORN, 0, 2, Q_BLOOD_MEDUSA, Q_SILVER_UNICORN, Q_GOLD_WYVERN)
      when 8
        return short_first_steps(qs, HAGGER, 3, 9, Q_SILVER_UNICORN, 0, 2, Q_BLOOD_MEDUSA, Q_SILVER_UNICORN, Q_GOLD_WYVERN)
      when 10
        return short_second_step_one_item(qs, HAGGER, 1, Q_SILVER_UNICORN, 2, Q_NIAS_SILVER_FAIRY, Q_BLOOD_MEDUSA, Q_BLOOD_WEREWOLF, Q_SILVER_UNICORN, Q_SILVER_GOLEM, Q_GOLD_WYVERN, Q_GOLD_DRAKE)
      when 11
        return short_second_step_one_item(qs, HAGGER, 5, Q_SILVER_UNICORN, 2, Q_NIAS_SILVER_FAIRY, Q_BLOOD_MEDUSA, Q_BLOOD_WEREWOLF, Q_SILVER_UNICORN, Q_SILVER_GOLEM, Q_GOLD_WYVERN, Q_GOLD_DRAKE)
      when 12
        return short_second_step_one_item(qs, HAGGER, 10, Q_SILVER_UNICORN, 2, Q_NIAS_SILVER_FAIRY, Q_BLOOD_MEDUSA, Q_BLOOD_WEREWOLF, Q_SILVER_UNICORN, Q_SILVER_GOLEM, Q_GOLD_WYVERN, Q_GOLD_DRAKE)
      when 19
        return short_third_step(qs, HAGGER, 1, Q_NIAS_SILVER_FAIRY, Q_BLOOD_WEREWOLF, Q_SILVER_GOLEM, Q_GOLD_DRAKE)
      when 20
        return short_third_step(qs, HAGGER, 2, Q_NIAS_SILVER_FAIRY, Q_BLOOD_WEREWOLF, Q_SILVER_GOLEM, Q_GOLD_DRAKE)
      when 21
        return short_third_step(qs, HAGGER, 3, Q_NIAS_SILVER_FAIRY, Q_BLOOD_WEREWOLF, Q_SILVER_GOLEM, Q_GOLD_DRAKE)
      end
    when STAN
      case event_id
      when 6
        return short_first_steps(qs, STAN, 1, 3, Q_SILVER_FAIRY, Q_SILVER_GOLEM, 1, Q_SILVER_FAIRY, Q_BLOOD_WEREWOLF, Q_GOLD_KNIGHT)
      when 7
        return short_first_steps(qs, STAN, 2, 7, Q_SILVER_FAIRY, Q_SILVER_GOLEM, 1, Q_SILVER_FAIRY, Q_BLOOD_WEREWOLF, Q_GOLD_KNIGHT)
      when 8
        return short_first_steps(qs, STAN, 3, 9, Q_SILVER_FAIRY, Q_SILVER_GOLEM, 1, Q_SILVER_FAIRY, Q_BLOOD_WEREWOLF, Q_GOLD_KNIGHT)
      when 10
        return short_second_step_two_items(qs, STAN, 1, Q_SILVER_FAIRY, Q_SILVER_GOLEM, Q_MANAKS_SILVER_DRYAD, Q_SILVER_FAIRY, Q_SILVER_GOLEM, Q_SILVER_DRYAD, Q_BLOOD_WEREWOLF, Q_BLOOD_DREVANUL, Q_BLOOD_BASILISK, Q_GOLD_KNIGHT, Q_GOLD_DRAKE, Q_GOLD_GIANT)
      when 11
        return short_second_step_two_items(qs, STAN, 5, Q_SILVER_FAIRY, Q_SILVER_GOLEM, Q_MANAKS_SILVER_DRYAD, Q_SILVER_FAIRY, Q_SILVER_GOLEM, Q_SILVER_DRYAD, Q_BLOOD_WEREWOLF, Q_BLOOD_DREVANUL, Q_BLOOD_BASILISK, Q_GOLD_KNIGHT, Q_GOLD_DRAKE, Q_GOLD_GIANT)
      when 12
        return short_second_step_two_items(qs, STAN, 10, Q_SILVER_FAIRY, Q_SILVER_GOLEM, Q_MANAKS_SILVER_DRYAD, Q_SILVER_FAIRY, Q_SILVER_GOLEM, Q_SILVER_DRYAD, Q_BLOOD_WEREWOLF, Q_BLOOD_DREVANUL, Q_BLOOD_BASILISK, Q_GOLD_KNIGHT, Q_GOLD_DRAKE, Q_GOLD_GIANT)
      when 19
        return short_third_step(qs, STAN, 1, Q_MANAKS_SILVER_DRYAD, Q_SILVER_DRYAD, Q_BLOOD_BASILISK, Q_GOLD_GIANT)
      when 20
        return short_third_step(qs, STAN, 2, Q_MANAKS_SILVER_DRYAD, Q_SILVER_DRYAD, Q_BLOOD_BASILISK, Q_GOLD_GIANT)
      when 21
        return short_third_step(qs, STAN, 3, Q_MANAKS_SILVER_DRYAD, Q_SILVER_DRYAD, Q_BLOOD_BASILISK, Q_GOLD_GIANT)
      end
    when RESEARCHER_LORAIN
      case event_id
      when 6
        return short_first_steps(qs, RESEARCHER_LORAIN, 1, 4, Q_GOLD_WYVERN, 0, 2, Q_BLOOD_MEDUSA, Q_SILVER_UNICORN, Q_GOLD_WYVERN)
      when 7
        return short_first_steps(qs, RESEARCHER_LORAIN, 2, 8, Q_GOLD_WYVERN, 0, 2, Q_BLOOD_MEDUSA, Q_SILVER_UNICORN, Q_GOLD_WYVERN)
      when 8
        return short_first_steps(qs, RESEARCHER_LORAIN, 3, 9, Q_GOLD_WYVERN, 0, 2, Q_BLOOD_MEDUSA, Q_SILVER_UNICORN, Q_GOLD_WYVERN)
      when 10
        return short_second_step_one_item(qs, RESEARCHER_LORAIN, 1, Q_GOLD_WYVERN, 2, Q_NIAS_GOLD_WYVERN, Q_BLOOD_MEDUSA, Q_BLOOD_DREVANUL, Q_SILVER_UNICORN, Q_SILVER_GOLEM, Q_GOLD_WYVERN, Q_GOLD_KNIGHT)
      when 11
        return short_second_step_one_item(qs, RESEARCHER_LORAIN, 5, Q_GOLD_WYVERN, 2, Q_NIAS_GOLD_WYVERN, Q_BLOOD_MEDUSA, Q_BLOOD_DREVANUL, Q_SILVER_UNICORN, Q_SILVER_GOLEM, Q_GOLD_WYVERN, Q_GOLD_KNIGHT)
      when 12
        return short_second_step_one_item(qs, RESEARCHER_LORAIN, 10, Q_GOLD_WYVERN, 2, Q_NIAS_GOLD_WYVERN, Q_BLOOD_MEDUSA, Q_BLOOD_DREVANUL, Q_SILVER_UNICORN, Q_SILVER_GOLEM, Q_GOLD_WYVERN, Q_GOLD_KNIGHT)
      when 19
        return short_third_step(qs, RESEARCHER_LORAIN, 1, Q_NIAS_GOLD_WYVERN, Q_BLOOD_DREVANUL, Q_SILVER_GOLEM, Q_GOLD_KNIGHT)
      when 20
        return short_third_step(qs, RESEARCHER_LORAIN, 2, Q_NIAS_GOLD_WYVERN, Q_BLOOD_DREVANUL, Q_SILVER_GOLEM, Q_GOLD_KNIGHT)
      when 21
        return short_third_step(qs, RESEARCHER_LORAIN, 3, Q_NIAS_GOLD_WYVERN, Q_BLOOD_DREVANUL, Q_SILVER_GOLEM, Q_GOLD_KNIGHT)
      end
    when BLACKSMITH_DUNING
      case event_id
      when 6
        return short_first_steps(qs, BLACKSMITH_DUNING, 1, 3, Q_GOLD_DRAKE, Q_GOLD_KNIGHT, 1, Q_SILVER_GOLEM, Q_BLOOD_DREVANUL, Q_GOLD_DRAKE)
      when 7
        return short_first_steps(qs, BLACKSMITH_DUNING, 2, 7, Q_GOLD_DRAKE, Q_GOLD_KNIGHT, 1, Q_SILVER_GOLEM, Q_BLOOD_DREVANUL, Q_GOLD_DRAKE)
      when 8
        return short_first_steps(qs, BLACKSMITH_DUNING, 3, 9, Q_GOLD_DRAKE, Q_GOLD_KNIGHT, 1, Q_SILVER_GOLEM, Q_BLOOD_DREVANUL, Q_GOLD_DRAKE)
      when 10
        return short_second_step_two_items(qs, BLACKSMITH_DUNING, 1, Q_GOLD_KNIGHT, Q_GOLD_DRAKE, Q_MANAKS_GOLD_GIANT, Q_SILVER_GOLEM, Q_SILVER_FAIRY, Q_SILVER_UNDINE, Q_BLOOD_DREVANUL, Q_BLOOD_WEREWOLF, Q_BLOOD_SUCCUBUS, Q_GOLD_DRAKE, Q_GOLD_KNIGHT, Q_GOLD_GIANT)
      when 11
        return short_second_step_two_items(qs, BLACKSMITH_DUNING, 5, Q_GOLD_KNIGHT, Q_GOLD_DRAKE, Q_MANAKS_GOLD_GIANT, Q_SILVER_GOLEM, Q_SILVER_FAIRY, Q_SILVER_UNDINE, Q_BLOOD_DREVANUL, Q_BLOOD_WEREWOLF, Q_BLOOD_SUCCUBUS, Q_GOLD_DRAKE, Q_GOLD_KNIGHT, Q_GOLD_GIANT)
      when 12
        return short_second_step_two_items(qs, BLACKSMITH_DUNING, 10, Q_GOLD_KNIGHT, Q_GOLD_DRAKE, Q_MANAKS_GOLD_GIANT, Q_SILVER_GOLEM, Q_SILVER_FAIRY, Q_SILVER_UNDINE, Q_BLOOD_DREVANUL, Q_BLOOD_WEREWOLF, Q_BLOOD_SUCCUBUS, Q_GOLD_DRAKE, Q_GOLD_KNIGHT, Q_GOLD_GIANT)
      when 19
        return short_third_step(qs, BLACKSMITH_DUNING, 1, Q_MANAKS_GOLD_GIANT, Q_SILVER_UNDINE, Q_BLOOD_SUCCUBUS, Q_GOLD_GIANT)
      when 20
        return short_third_step(qs, BLACKSMITH_DUNING, 2, Q_MANAKS_GOLD_GIANT, Q_SILVER_UNDINE, Q_BLOOD_SUCCUBUS, Q_GOLD_GIANT)
      when 21
        return short_third_step(qs, BLACKSMITH_DUNING, 3, Q_MANAKS_GOLD_GIANT, Q_SILVER_UNDINE, Q_BLOOD_SUCCUBUS, Q_GOLD_GIANT)
      end
    when MAGISTER_PAGE
      case event_id
      when 6
        return short_first_steps(qs, MAGISTER_PAGE, 1, 4, Q_BLOOD_MEDUSA, 0, 2, Q_BLOOD_MEDUSA, Q_SILVER_UNICORN, Q_GOLD_WYVERN)
      when 7
        return short_first_steps(qs, MAGISTER_PAGE, 2, 8, Q_BLOOD_MEDUSA, 0, 2, Q_BLOOD_MEDUSA, Q_SILVER_UNICORN, Q_GOLD_WYVERN)
      when 8
        return short_first_steps(qs, MAGISTER_PAGE, 3, 9, Q_BLOOD_MEDUSA, 0, 2, Q_BLOOD_MEDUSA, Q_SILVER_UNICORN, Q_GOLD_WYVERN)
      when 10
        return short_second_step_one_item(qs, MAGISTER_PAGE, 1, Q_BLOOD_MEDUSA, 2, Q_NIAS_BLOOD_MEDUSA, Q_BLOOD_MEDUSA, Q_BLOOD_WEREWOLF, Q_SILVER_UNICORN, Q_SILVER_FAIRY, Q_GOLD_WYVERN, Q_GOLD_KNIGHT)
      when 11
        return short_second_step_one_item(qs, MAGISTER_PAGE, 5, Q_BLOOD_MEDUSA, 2, Q_NIAS_BLOOD_MEDUSA, Q_BLOOD_MEDUSA, Q_BLOOD_WEREWOLF, Q_SILVER_UNICORN, Q_SILVER_FAIRY, Q_GOLD_WYVERN, Q_GOLD_KNIGHT)
      when 12
        return short_second_step_one_item(qs, MAGISTER_PAGE, 10, Q_BLOOD_MEDUSA, 2, Q_NIAS_BLOOD_MEDUSA, Q_BLOOD_MEDUSA, Q_BLOOD_WEREWOLF, Q_SILVER_UNICORN, Q_SILVER_FAIRY, Q_GOLD_WYVERN, Q_GOLD_KNIGHT)
      when 19
        return short_third_step(qs, MAGISTER_PAGE, 1, Q_NIAS_BLOOD_MEDUSA, Q_BLOOD_WEREWOLF, Q_SILVER_FAIRY, Q_GOLD_KNIGHT)
      when 20
        return short_third_step(qs, MAGISTER_PAGE, 2, Q_NIAS_BLOOD_MEDUSA, Q_BLOOD_WEREWOLF, Q_SILVER_FAIRY, Q_GOLD_KNIGHT)
      when 21
        return short_third_step(qs, MAGISTER_PAGE, 3, Q_NIAS_BLOOD_MEDUSA, Q_BLOOD_WEREWOLF, Q_SILVER_FAIRY, Q_GOLD_KNIGHT)
      end
    when HEAD_BLACKSMITH_FERRIS
      case event.to_i
      when 6
        return short_first_steps(qs, HEAD_BLACKSMITH_FERRIS, 1, 4, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, 1, Q_GOLD_GIANT, Q_SILVER_DRYAD, Q_BLOOD_BASILISK)
      when 7
        return short_first_steps(qs, HEAD_BLACKSMITH_FERRIS, 2, 8, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, 1, Q_GOLD_GIANT, Q_SILVER_DRYAD, Q_BLOOD_BASILISK)
      when 8
        return short_first_steps(qs, HEAD_BLACKSMITH_FERRIS, 3, 9, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, 1, Q_GOLD_GIANT, Q_SILVER_DRYAD, Q_BLOOD_BASILISK)
      when 10
        return short_second_step_two_items(qs, HEAD_BLACKSMITH_FERRIS, 1, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_BERETHS_BLOOD_DRAGON, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_GOLD_DRAGON, Q_SILVER_DRYAD, Q_SILVER_UNDINE, Q_SILVER_DRAGON, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_BLOOD_DRAGON)
      when 11
        return short_second_step_two_items(qs, HEAD_BLACKSMITH_FERRIS, 5, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_BERETHS_BLOOD_DRAGON, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_GOLD_DRAGON, Q_SILVER_DRYAD, Q_SILVER_UNDINE, Q_SILVER_DRAGON, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_BLOOD_DRAGON)
      when 12
        return short_second_step_two_items(qs, HEAD_BLACKSMITH_FERRIS, 10, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_BERETHS_BLOOD_DRAGON, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_GOLD_DRAGON, Q_SILVER_DRYAD, Q_SILVER_UNDINE, Q_SILVER_DRAGON, Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_BLOOD_DRAGON)
      when 19
        return short_third_step(qs, HEAD_BLACKSMITH_FERRIS, 1, Q_BERETHS_BLOOD_DRAGON, Q_GOLD_DRAGON, Q_SILVER_DRAGON, Q_BLOOD_DRAGON)
      when 20
        return short_third_step(qs, HEAD_BLACKSMITH_FERRIS, 2, Q_BERETHS_BLOOD_DRAGON, Q_GOLD_DRAGON, Q_SILVER_DRAGON, Q_BLOOD_DRAGON)
      when 21
        return short_third_step(qs, HEAD_BLACKSMITH_FERRIS, 3, Q_BERETHS_BLOOD_DRAGON, Q_GOLD_DRAGON, Q_SILVER_DRAGON, Q_BLOOD_DRAGON)
      end
    when UNION_PRESIDENT_BERNARD
      case event_id
      when 1
        return "30702-02.html"
      when 2
        qs.memo_state = 2
        qs.set_cond(2)
        qs.show_question_mark(336)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "30702-03.html"
      when 3
        qs.memo_state = 2
        qs.set_cond(2)
        qs.show_question_mark(336)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "30702-04.html"
      when 4
        qs.set_cond(7)
        qs.show_question_mark(336)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "30702-06.html"
      end
    when WAREHOUSE_KEEPER_SORINT
      case event_id
      when 1
        return "30232-03.html"
      when 2
        return "30232-04.html"
      when 3
        return "30232-08.html"
      when 4
        return "30232-09.html"
      when 5
        if qs.has_quest_items?(Q_CC_MEMBERSHIP_3)
          if qs.has_quest_items?(Q_BLOOD_DREVANUL, Q_BLOOD_WEREWOLF, Q_GOLD_KNIGHT, Q_GOLD_DRAKE, Q_SILVER_FAIRY, Q_SILVER_GOLEM)
            qs.set_cond(9)
            qs.show_question_mark(336)
            qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            qs.take_items(Q_CC_MEMBERSHIP_3, -1)
            qs.take_items(Q_BLOOD_DREVANUL, 1)
            qs.take_items(Q_BLOOD_WEREWOLF, 1)
            qs.take_items(Q_GOLD_KNIGHT, 1)
            qs.take_items(Q_GOLD_DRAKE, 1)
            qs.take_items(Q_SILVER_FAIRY, 1)
            qs.take_items(Q_SILVER_GOLEM, 1)
            qs.give_items(Q_CC_MEMBERSHIP_2, 1)
            return "30232-16.html"
          end
          qs.set_cond(8)
          qs.show_question_mark(336)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-13.html"
        end
        if qs.has_quest_items?(Q_CC_MEMBERSHIP_2)
          if qs.has_quest_items?(Q_BLOOD_BASILISK, Q_BLOOD_SUCCUBUS, Q_GOLD_GIANT, Q_GOLD_WYRM, Q_SILVER_UNDINE, Q_SILVER_DRYAD)
            qs.set_cond(11)
            qs.show_question_mark(336)
            qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
            qs.take_items(Q_CC_MEMBERSHIP_2, -1)
            qs.take_items(Q_BLOOD_BASILISK, 1)
            qs.take_items(Q_BLOOD_SUCCUBUS, 1)
            qs.take_items(Q_GOLD_GIANT, 1)
            qs.take_items(Q_GOLD_WYRM, 1)
            qs.take_items(Q_SILVER_UNDINE, 1)
            qs.take_items(Q_SILVER_DRYAD, 1)
            qs.give_items(Q_CC_MEMBERSHIP_1, 1)
            return "30232-17.html"
          end
          qs.set_cond(10)
          qs.show_question_mark(336)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-14.html"
        end
        if qs.has_quest_items?(Q_CC_MEMBERSHIP_1)
          return "30232-15.html"
        end
      when 6
        return "30232-18.html"
      when 7
        return "30232-19.html"
      when 8
        return "30232-20.html"
      when 9
        return "30232-21.html"
      when 10
        qs.set_cond(6)
        qs.show_question_mark(336)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "30232-22.html"
      when 11
        qs.set_cond(5)
        qs.show_question_mark(336)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "30232-23.html"
      when 20
        if qs.has_quest_items?(Q_BERETHS_BLOOD_DRAGON) && qs.has_quest_items?(Q_SILVER_DRAGON) && (qs.get_quest_items_count(Q_GOLD_WYRM) >= 13)
          qs.take_items(Q_BERETHS_BLOOD_DRAGON, 1)
          qs.take_items(Q_SILVER_DRAGON, 1)
          qs.take_items(Q_GOLD_WYRM, 13)
          qs.give_items(DEMON_STAFF, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-24a.html"
        end
        return "30232-24.html"
      when 21
        if qs.has_quest_items?(Q_BERETHS_GOLD_DRAGON) && qs.has_quest_items?(Q_BLOOD_DRAGON) && qs.has_quest_items?(Q_SILVER_DRYAD) && qs.has_quest_items?(Q_GOLD_GIANT)
          qs.take_items(Q_BERETHS_GOLD_DRAGON, 1)
          qs.take_items(Q_BLOOD_DRAGON, 1)
          qs.take_items(Q_SILVER_DRYAD, 1)
          qs.take_items(Q_GOLD_GIANT, 1)
          qs.give_items(DARK_SCREAMER, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-24b.html"
        end
        return "30232-24.html"
      when 22
        if qs.has_quest_items?(Q_BERETHS_SILVER_DRAGON) && qs.has_quest_items?(Q_GOLD_DRAGON) && qs.has_quest_items?(Q_BLOOD_SUCCUBUS) && (qs.get_quest_items_count(Q_BLOOD_BASILISK) >= 2)
          qs.take_items(Q_BERETHS_SILVER_DRAGON, 1)
          qs.take_items(Q_GOLD_DRAGON, 1)
          qs.take_items(Q_BLOOD_SUCCUBUS, 1)
          qs.take_items(Q_BLOOD_BASILISK, 2)
          qs.give_items(WIDOW_MAKER, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-24c.html"
        end
        return "30232-24.html"
      when 23
        if qs.has_quest_items?(Q_GOLD_DRAGON) && qs.has_quest_items?(Q_SILVER_DRAGON) && qs.has_quest_items?(Q_BLOOD_DRAGON) && qs.has_quest_items?(Q_SILVER_UNDINE)
          qs.take_items(Q_GOLD_DRAGON, 1)
          qs.take_items(Q_SILVER_DRAGON, 1)
          qs.take_items(Q_BLOOD_DRAGON, 1)
          qs.take_items(Q_SILVER_UNDINE, 1)
          qs.give_items(SWORD_OF_LIMIT, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-24d.html"
        end
        return "30232-24.html"
      when 24
        if qs.has_quest_items?(Q_MANAKS_GOLD_GIANT)
          qs.take_items(Q_MANAKS_GOLD_GIANT, 1)
          qs.give_items(DEMONS_BOOTS, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-24e.html"
        end
        return "30232-24.html"
      when 25
        if qs.has_quest_items?(Q_MANAKS_SILVER_DRYAD) && qs.has_quest_items?(Q_SILVER_DRYAD)
          qs.take_items(Q_MANAKS_SILVER_DRYAD, 1)
          qs.take_items(Q_SILVER_DRYAD, 1)
          qs.give_items(DEMONS_HOSE, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-24f.html"
        end
        return "30232-24.html"
      when 26
        if qs.has_quest_items?(Q_MANAKS_GOLD_GIANT)
          qs.take_items(Q_MANAKS_GOLD_GIANT, 1)
          qs.give_items(DEMONS_GLOVES, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-24g.html"
        end
        return "30232-24.html"
      when 27
        if qs.has_quest_items?(Q_MANAKS_BLOOD_WEREWOLF) && qs.has_quest_items?(Q_GOLD_GIANT) && qs.has_quest_items?(Q_GOLD_WYRM)
          qs.take_items(Q_MANAKS_BLOOD_WEREWOLF, 1)
          qs.take_items(Q_GOLD_GIANT, 1)
          qs.take_items(Q_GOLD_WYRM, 1)
          qs.give_items(FULL_PLATE_HELMET, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-24h.html"
        end
        return "30232-24.html"
      when 28
        if qs.get_quest_items_count(Q_NIAS_BLOOD_MEDUSA) >= 2 && qs.get_quest_items_count(Q_GOLD_DRAKE) >= 2 && qs.get_quest_items_count(Q_BLOOD_DREVANUL) >= 2 && qs.get_quest_items_count(Q_GOLD_KNIGHT) >= 3
          qs.take_items(Q_NIAS_BLOOD_MEDUSA, 2)
          qs.take_items(Q_GOLD_DRAKE, 2)
          qs.take_items(Q_BLOOD_DREVANUL, 2)
          qs.take_items(Q_GOLD_KNIGHT, 3)
          qs.give_items(MOONSTONE_EARING, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-24i.html"
        end
        return "30232-24.html"
      when 29
        if qs.get_quest_items_count(Q_NIAS_BLOOD_MEDUSA) >= 7 && qs.get_quest_items_count(Q_GOLD_KNIGHT) >= 5 && qs.get_quest_items_count(Q_BLOOD_DREVANUL) >= 5 && qs.get_quest_items_count(Q_SILVER_GOLEM) >= 5
          qs.take_items(Q_NIAS_BLOOD_MEDUSA, 7)
          qs.take_items(Q_GOLD_KNIGHT, 5)
          qs.take_items(Q_BLOOD_DREVANUL, 5)
          qs.take_items(Q_SILVER_GOLEM, 5)
          qs.give_items(NASSENS_EARING, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-24j.html"
        end
        return "30232-24.html"
      when 30
        if qs.get_quest_items_count(Q_NIAS_GOLD_WYVERN) >= 5 && qs.get_quest_items_count(Q_SILVER_GOLEM) >= 4 && qs.get_quest_items_count(Q_GOLD_DRAKE) >= 4 && qs.get_quest_items_count(Q_BLOOD_DREVANUL) >= 4
          qs.take_items(Q_NIAS_GOLD_WYVERN, 5)
          qs.take_items(Q_SILVER_GOLEM, 4)
          qs.take_items(Q_GOLD_DRAKE, 4)
          qs.take_items(Q_BLOOD_DREVANUL, 4)
          qs.give_items(RING_OF_BINDING, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-24k.html"
        end
        return "30232-24.html"
      when 31
        if qs.get_quest_items_count(Q_NIAS_SILVER_FAIRY) >= 5 && qs.get_quest_items_count(Q_SILVER_FAIRY) >= 3 && qs.get_quest_items_count(Q_GOLD_KNIGHT) >= 3 && qs.get_quest_items_count(Q_BLOOD_DREVANUL) >= 3
          qs.take_items(Q_NIAS_SILVER_FAIRY, 5)
          qs.take_items(Q_SILVER_FAIRY, 3)
          qs.take_items(Q_GOLD_KNIGHT, 3)
          qs.take_items(Q_BLOOD_DREVANUL, 3)
          qs.give_items(NECKLACE_OF_PROTECTION, 1)
          qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
          return "30232-24l.html"
        end
        return "30232-24.html"
      when 100
        qs.take_items(Q_CC_MEMBERSHIP_1, -1)
        qs.take_items(Q_CC_MEMBERSHIP_2, -1)
        qs.take_items(Q_CC_MEMBERSHIP_3, -1)
        qs.play_sound(Sound::ITEMSOUND_QUEST_FINISH)
        qs.exit_quest(true)
        return "30232-18a.html"
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    case npc.id
    when HARIT_LIZARDMAN_SHAMAN, HARIT_LIZARDM_MATRIARCH
      if qs = get_random_player_from_party_coin(killer, npc, 2)
        if Rnd.rand(1000) < 63
          give_item_randomly(qs.player, npc, Q_KALDIS_GOLD_DRAGON, 1, 0, 1, true)
          qs.set_cond(3)
          qs.show_question_mark(336)
        end
      end

      return super
    end

    if qs = get_random_player_from_party(killer, npc, 3)
      case npc.id
      when SHACKLE, SHACKLE_HOLD
        if Rnd.rand(1000) < 70
          give_item_randomly(qs.player, npc, Q_GOLD_WYVERN, 1, 0, 1, true)
        end
      when HEADLESS_KNIGHT, TIMAK_ORC
        if Rnd.rand(1000) < 80
          give_item_randomly(qs.player, npc, Q_GOLD_WYVERN, 1, 0, 1, true)
        end
      when HEADLESS_KNIGHT_HOLD
        if Rnd.rand(1000) < 85
          give_item_randomly(qs.player, npc, Q_GOLD_WYVERN, 1, 0, 1, true)
        end
      when ROYAL_CAVE_SERVANT, MALRUK_SUCCUBUS_TUREN, ROYAL_CAVE_SERVANT_HOLD,
           KUKABURO_B, ANTELOPE, ANTELOPE_A, ANTELOPE_B, H_MALRUK_SUCCUBUS_TUREN
        if Rnd.rand(1000) < 100
          give_item_randomly(qs.player, npc, Q_GOLD_WYVERN, 1, 0, 1, true)
        end
      when BUFFALO, BUFFALO_A, BUFFALO_B, KUKABURO, KUKABURO_A
        if Rnd.rand(1000) < 110
          give_item_randomly(qs.player, npc, Q_GOLD_WYVERN, 1, 0, 1, true)
        end
      when DOOM_SERVANT
        if Rnd.rand(1000) < 140
          give_item_randomly(qs.player, npc, Q_GOLD_WYVERN, 1, 0, 1, true)
        end
      when DOOM_KNIGHT
        if Rnd.rand(1000) < 210
          give_item_randomly(qs.player, npc, Q_GOLD_WYVERN, 1, 0, 1, true)
        end
      when VANOR_SILENOS_SHAMAN
        if Rnd.rand(1000) < 70
          give_item_randomly(qs.player, npc, Q_SILVER_UNICORN, 1, 0, 1, true)
        end
      when BLOODY_GHOST, TARLK_BUGBEAR_BOSS, OEL_MAHUM
        if Rnd.rand(1000) < 80
          give_item_randomly(qs.player, npc, Q_SILVER_UNICORN, 1, 0, 1, true)
        end
      when OEL_MAHUM_WARRIOR
        if Rnd.rand(1000) < 90
          give_item_randomly(qs.player, npc, Q_SILVER_UNICORN, 1, 0, 1, true)
        end
      when HUNGRY_CORPSE
        if Rnd.rand(1000) < 100
          give_item_randomly(qs.player, npc, Q_SILVER_UNICORN, 1, 0, 1, true)
        end
      when BYFOOT
        if Rnd.rand(1000) < 110
          give_item_randomly(qs.player, npc, Q_SILVER_UNICORN, 1, 0, 1, true)
        end
      when BYFOOT_SIGEL
        if Rnd.rand(1000) < 120
          give_item_randomly(qs.player, npc, Q_SILVER_UNICORN, 1, 0, 1, true)
        end
      when DARK_GUARD, BRILLIANT_CLAW, BRILLIANT_CLAW_1
        if Rnd.rand(1000) < 150
          give_item_randomly(qs.player, npc, Q_SILVER_UNICORN, 1, 0, 1, true)
        end
      when OEL_MAHUM_WITCH_DOCTOR
        if Rnd.rand(1000) < 200
          give_item_randomly(qs.player, npc, Q_SILVER_UNICORN, 1, 0, 1, true)
        end
      when BRILLIANT_ANGUISH, BRILLIANT_ANGUISH_1
        if Rnd.rand(1000) < 210
          give_item_randomly(qs.player, npc, Q_SILVER_UNICORN, 1, 0, 1, true)
        end
      when LAKIN
        if Rnd.rand(1000) < 60
          give_item_randomly(qs.player, npc, Q_BLOOD_MEDUSA, 1, 0, 1, true)
        end
      when HATAR_HANISHEE
        if Rnd.rand(1000) < 70
          give_item_randomly(qs.player, npc, Q_BLOOD_MEDUSA, 1, 0, 1, true)
        end
      when PUNISHMENT_OF_UNDEAD
        if Rnd.rand(1000) < 80
          give_item_randomly(qs.player, npc, Q_BLOOD_MEDUSA, 1, 0, 1, true)
        end
      when FLOAT_OF_GRAVE, BANDERSNATCH_A, BANDERSNATCH_B
        if Rnd.rand(1000) < 90
          give_item_randomly(qs.player, npc, Q_BLOOD_MEDUSA, 1, 0, 1, true)
        end
      when BANDERSNATCH
        if Rnd.rand(1000) < 100
          give_item_randomly(qs.player, npc, Q_BLOOD_MEDUSA, 1, 0, 1, true)
        end
      when NIHIL_INVADER
        if Rnd.rand(1000) < 110
          give_item_randomly(qs.player, npc, Q_BLOOD_MEDUSA, 1, 0, 1, true)
        end
      when TIMAK_ORC_SHAMAN
        if Rnd.rand(1000) < 130
          give_item_randomly(qs.player, npc, Q_BLOOD_MEDUSA, 1, 0, 1, true)
        end
      when TIMAK_ORC_ARCHER, TIMAK_ORC_SOLDIER
        if Rnd.rand(1000) < 140
          give_item_randomly(qs.player, npc, Q_BLOOD_MEDUSA, 1, 0, 1, true)
        end
      when DOOM_ARCHER, BRILLIANT_WISDOM, BRILLIANT_VENGEANCE, BRILLIANT_VENGEANCE_1
        if Rnd.rand(1000) < 160
          give_item_randomly(qs.player, npc, Q_BLOOD_MEDUSA, 1, 0, 1, true)
        end
      end
    end

    super
  end

  private def reset_params(qs)
    qs.set(WEIGHT_POINT, 0)
    qs.set(PARAM_1, 0)
    qs.set(PARAM_2, 0)
    qs.set(PARAM_3, 0)
    qs.set(FLAG, 0)
  end

  private def short_first_steps(qs, npc_id, weight_point, base, item_1_1, item_1_2, item_1_mul, item_2, item_3, item_4)
    case qs.get_int(PARAM_2)
    when 42
      if qs.get_quest_items_count(item_1_1) >= base * item_1_mul && (item_1_2 == 0 || qs.get_quest_items_count(item_1_2) >= base)
        qs.set(FLAG, 1)
        qs.take_items(item_1_1, base * item_1_mul)
        if item_1_2 > 0
          qs.take_items(item_1_2, base)
        end
        qs.set(WEIGHT_POINT, weight_point)
        param1 = Rnd.rand(3) + 1
        param1 += (Rnd.rand(3) + 1) * 4
        param1 += (Rnd.rand(3) + 1) * 16
        qs.set(PARAM_1, param1)
        return "#{npc_id}-11.html"
      end
    when 31
      if qs.get_quest_items_count(item_2) >= base
        qs.set(FLAG, 1)
        qs.take_items(item_2, base)
        qs.set(WEIGHT_POINT, weight_point)
        param1 = Rnd.rand(3) + 1
        param1 += (Rnd.rand(3) + 1) * 4
        param1 += (Rnd.rand(3) + 1) * 16
        qs.set(PARAM_1, param1)
        return "#{npc_id}-11.html"
      end
    when 21
      if qs.get_quest_items_count(item_3) >= base
        qs.set(FLAG, 1)
        qs.take_items(item_3, base)
        qs.set(WEIGHT_POINT, weight_point)
        param1 = Rnd.rand(3) + 1
        param1 += (Rnd.rand(3) + 1) * 4
        param1 += (Rnd.rand(3) + 1) * 16
        qs.set(PARAM_1, param1)
        return "#{npc_id}-11.html"
      end
    when 11
      if qs.get_quest_items_count(item_4) >= base
        qs.set(FLAG, 1)
        qs.take_items(item_4, base)
        qs.set(WEIGHT_POINT, weight_point)
        param1 = Rnd.rand(3) + 1
        param1 += (Rnd.rand(3) + 1) * 4
        param1 += (Rnd.rand(3) + 1) * 16
        qs.set(PARAM_1, param1)
        return "#{npc_id}-11.html"
      end
    end

    "#{npc_id}-10.html"
  end

  private def short_second_step_one_item(qs, npc_id, mul, item_1, item_1_mul, reward_1, item_2, reward_2, item_3, reward_3, item_4, reward_4)
    case qs.get_int(PARAM_2)
    when 42
      if qs.get_quest_items_count(item_1) >= 10 * mul * item_1_mul
        qs.take_items(item_1, 10 * mul * item_1_mul)
        qs.give_items(reward_1, 1 * mul)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "#{npc_id}-07.html"
      end
    when 31
      if qs.get_quest_items_count(item_2) >= 5 * mul
        qs.take_items(item_2, 5 * mul)
        qs.give_items(reward_2, 1 * mul)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "#{npc_id}-07.html"
      end
    when 21
      if qs.get_quest_items_count(item_3) >= 5 * mul
        qs.take_items(item_3, 5 * mul)
        qs.give_items(reward_3, 1 * mul)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "#{npc_id}-07.html"
      end
    when 11
      if qs.get_quest_items_count(item_4) >= 5 * mul
        qs.take_items(item_4, 5 * mul)
        qs.give_items(reward_4, 1 * mul)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "#{npc_id}-07.html"
      end
    end

    "#{npc_id}-10.html"
  end

  private def short_second_step_two_items(qs, npc_id, mul, item_1_1, item_1_2, reward_1, item_2_1, item_2_2, reward_2, item_3_1, item_3_2, reward_3, item_4_1, item_4_2, reward_4)
    case qs.get_int(PARAM_2)
    when 42
      if qs.get_quest_items_count(item_1_1) >= 10 * mul && qs.get_quest_items_count(item_1_2) >= 10 * mul
        qs.take_items(item_1_1, 10 * mul)
        qs.take_items(item_1_2, 10 * mul)
        qs.give_items(reward_1, 1 * mul)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "#{npc_id}-07.html"
      end
    when 31
      if qs.get_quest_items_count(item_2_1) >= 5 * mul && qs.get_quest_items_count(item_2_2) >= 5 * mul
        qs.take_items(item_2_1, 5 * mul)
        qs.take_items(item_2_2, 5 * mul)
        qs.give_items(reward_2, 1 * mul)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "#{npc_id}-07.html"
      end
    when 21
      if qs.get_quest_items_count(item_3_1) >= 5 * mul && qs.get_quest_items_count(item_3_2) >= 5 * mul
        qs.take_items(item_3_1, 5 * mul)
        qs.take_items(item_3_2, 5 * mul)
        qs.give_items(reward_3, 1 * mul)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "#{npc_id}-07.html"
      end
    when 11
      if qs.get_quest_items_count(item_4_1) >= 5 * mul && qs.get_quest_items_count(item_4_2) >= 5 * mul
        qs.take_items(item_4_1, 5 * mul)
        qs.take_items(item_4_2, 5 * mul)
        qs.give_items(reward_4, 1 * mul)
        qs.play_sound(Sound::ITEMSOUND_QUEST_MIDDLE)
        return "#{npc_id}-07.html"
      end
    end

    "#{npc_id}-10.html"
  end

  private def short_third_step(qs, npc_id, flag, item_1, item_2, item_3, item_4)
    qs.set(PARAM_3, 0)
    qs.set(FLAG, qs.get_int(FLAG) + flag)
    if qs.get_int(PARAM_1) == qs.get_int(FLAG) && qs.get_int(WEIGHT_POINT) >= 0
      qs.set(WEIGHT_POINT, 0)
      case qs.get_int(PARAM_2)
      when 42
        qs.give_items(item_1, 1)
      when 31
        qs.give_items(item_2, 1)
      when 21
        qs.give_items(item_3, 1)
      when 11
        qs.give_items(item_4, 1)
      end

      qs.set(PARAM_1, 0)
      return "#{npc_id}-20.html"
    elsif qs.get_int(WEIGHT_POINT) == 0
      case qs.get_int(PARAM_1)
      when 21
        return "#{npc_id}-23.html"
      when 25
        return "#{npc_id}-24.html"
      when 37
        return "#{npc_id}-25.html"
      when 41
        return "#{npc_id}-26.html"
      when 61
        return "#{npc_id}-27.html"
      when 29
        return "#{npc_id}-28.html"
      when 45
        return "#{npc_id}-29.html"
      when 53
        return "#{npc_id}-30.html"
      when 57
        return "#{npc_id}-31.html"
      when 22
        return "#{npc_id}-32.html"
      when 26
        return "#{npc_id}-33.html"
      when 38
        return "#{npc_id}-34.html"
      when 42
        return "#{npc_id}-35.html"
      when 62
        return "#{npc_id}-36.html"
      when 30
        return "#{npc_id}-37.html"
      when 46
        return "#{npc_id}-38.html"
      when 54
        return "#{npc_id}-39.html"
      when 58
        return "#{npc_id}-40.html"
      when 23
        return "#{npc_id}-41.html"
      when 27
        return "#{npc_id}-42.html"
      when 39
        return "#{npc_id}-43.html"
      when 43
        return "#{npc_id}-44.html"
      when 63
        return "#{npc_id}-45.html"
      when 31
        return "#{npc_id}-46.html"
      when 47
        return "#{npc_id}-47.html"
      when 55
        return "#{npc_id}-48.html"
      when 59
        return "#{npc_id}-49.html"
      end

      qs.set(PARAM_1, 0)
    else
      i0 = qs.get_int(PARAM_1) % 4
      i1 = qs.get_int(PARAM_1) / 4
      i2 = i1 / 4
      i1 = i1 % 4

      i3 = qs.get_int(FLAG) % 4
      i4 = qs.get_int(FLAG) / 4
      i5 = i4 / 4
      i4 = i4 % 4

      if i0 == i3
        qs.set(PARAM_3, qs.get_int(PARAM_3) + 1)
      end
      if i1 == i4
        qs.set(PARAM_3, qs.get_int(PARAM_3) + 1)
      end
      if i2 == i5
        qs.set(PARAM_3, qs.get_int(PARAM_3) + 1)
      end
      qs.set(FLAG, 1)
      qs.set(WEIGHT_POINT, qs.get_int(WEIGHT_POINT) - 1)
      case qs.get_int(PARAM_3)
      when 0
        return "#{npc_id}-52.html"
      when 1
        return "#{npc_id}-50.html"
      when 2
        return "#{npc_id}-51.html"
      end
    end
  end

  private def get_random_player_from_party(pc, npc, memo_state)
    qs = get_quest_state(pc, false)
    candidates = [] of QuestState

    if qs && qs.started? && qs.memo_state == memo_state
      candidates.push(qs, qs)
    end

    if party = pc.party
      party.members.each do |pm|
        qss = get_quest_state(pm, false)
        if qss && qss.started? && qss.memo_state == memo_state
          if Util.in_range?(1500, npc, pm, true)
            candidates << qss
          end
        end
      end
    end

    candidates.sample?(random: Rnd)
  end

  private def get_random_player_from_party_coin(pc, npc, memo_state)
    qs = get_quest_state(pc, false)
    candidates = [] of QuestState
    if qs && qs.started? && qs.memo_state == memo_state
      unless qs.has_quest_items?(Q_KALDIS_GOLD_DRAGON)
        candidates.push(qs, qs)
      end
    end

    if party = pc.party
      party.members.each do |pm|
        qss = get_quest_state(pm, false)
        if qss && qss.started? && qss.memo_state == memo_state
          unless qss.has_quest_items?(Q_KALDIS_GOLD_DRAGON)
            if Util.in_range?(1500, npc, pm, true)
              candidates << qss
            end
          end
        end
      end
    end

    candidates.sample?(random: Rnd)
  end
end
