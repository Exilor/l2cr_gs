class Scripts::Q00232_TestOfTheLord < Quest
  # NPCs
  private SEER_SOMAK = 30510
  private SEER_MANAKIA = 30515
  private TRADER_JAKAL = 30558
  private BLACKSMITH_SUMARI = 30564
  private FLAME_LORD_KAKAI = 30565
  private ATUBA_CHIEF_VARKEES = 30566
  private NERUGA_CHIEF_TANTUS = 30567
  private URUTU_CHIEF_HATOS = 30568
  private DUDA_MARA_CHIEF_TAKUNA = 30641
  private GANDI_CHIEF_CHIANTA = 30642
  private FIRST_ORC = 30643
  private ANCESTOR_MARTANKUS = 30649
  # Items
  private ADENA = 57
  private BONE_ARROW = 1341
  private ORDEAL_NECKLACE = 3391
  private VARKEES_CHARM = 3392
  private TANTUS_CHARM = 3393
  private HATOS_CHARM = 3394
  private TAKUNA_CHARM = 3395
  private CHIANTA_CHARM = 3396
  private MANAKIAS_ORDERS = 3397
  private BREKA_ORC_FANG = 3398
  private MANAKIAS_AMULET = 3399
  private HUGE_ORC_FANG = 3400
  private SUMARIS_LETTER = 3401
  private URUTU_BLADE = 3402
  private TIMAK_ORC_SKULL = 3403
  private SWORD_INTO_SKULL = 3404
  private NERUGA_AXE_BLADE = 3405
  private AXE_OF_CEREMONY = 3406
  private MARSH_SPIDER_FEELER = 3407
  private MARSH_SPIDER_FEET = 3408
  private HANDIWORK_SPIDER_BROOCH = 3409
  private ENCHANTED_MONSTER_CORNEA = 3410
  private MONSTER_EYE_WOODCARVING = 3411
  private BEAR_FANG_NECKLACE = 3412
  private MARTANKUS_CHARM = 3413
  private RAGNA_ORC_HEAD = 3414
  private RAGNA_CHIEF_NOTICE = 3415
  private IMMORTAL_FLAME = 3416
  # Reward
  private MARK_OF_LORD = 3390
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private MARSH_SPIDER = 20233
  private BREKA_ORC_SHAMAN = 20269
  private BREKA_ORC_OVERLORD = 20270
  private ENCHANTED_MONSTEREYE = 20564
  private TIMAK_ORC = 20583
  private TIMAK_ORC_ARCHER = 20584
  private TIMAK_ORC_SOLDIER = 20585
  private TIMAK_ORC_WARRIOR = 20586
  private TIMAK_ORC_SHAMAN = 20587
  private TIMAK_ORC_OVERLORD = 20588
  private RAGNA_ORC_OVERLORD = 20778
  private RAGNA_ORC_SEER = 20779
  # Misc
  private MIN_LEVEL = 39
  # Locations
  private FIRST_ORC_SPAWN = Location.new(21036, -107690, -3038)

  def initialize
    super(232, self.class.simple_name, "Test Of The Lord")

    add_start_npc(FLAME_LORD_KAKAI)
    add_talk_id(
      FLAME_LORD_KAKAI, SEER_SOMAK, SEER_MANAKIA, TRADER_JAKAL,
      BLACKSMITH_SUMARI, ATUBA_CHIEF_VARKEES, NERUGA_CHIEF_TANTUS,
      URUTU_CHIEF_HATOS, DUDA_MARA_CHIEF_TAKUNA, GANDI_CHIEF_CHIANTA, FIRST_ORC,
      ANCESTOR_MARTANKUS
    )
    add_kill_id(
      MARSH_SPIDER, BREKA_ORC_SHAMAN, BREKA_ORC_OVERLORD, ENCHANTED_MONSTEREYE,
      TIMAK_ORC, TIMAK_ORC_ARCHER, TIMAK_ORC_SOLDIER, TIMAK_ORC_SOLDIER,
      TIMAK_ORC_WARRIOR, TIMAK_ORC_SHAMAN, TIMAK_ORC_OVERLORD,
      RAGNA_ORC_OVERLORD, RAGNA_ORC_SEER
    )
    register_quest_items(
      ORDEAL_NECKLACE, VARKEES_CHARM, TANTUS_CHARM, HATOS_CHARM, TAKUNA_CHARM,
      CHIANTA_CHARM, MANAKIAS_ORDERS, BREKA_ORC_FANG, MANAKIAS_AMULET,
      HUGE_ORC_FANG, SUMARIS_LETTER, URUTU_BLADE, TIMAK_ORC_SKULL,
      SWORD_INTO_SKULL, NERUGA_AXE_BLADE, AXE_OF_CEREMONY, MARSH_SPIDER_FEELER,
      MARSH_SPIDER_FEET, HANDIWORK_SPIDER_BROOCH, ENCHANTED_MONSTER_CORNEA,
      MONSTER_EYE_WOODCARVING, BEAR_FANG_NECKLACE, MARTANKUS_CHARM,
      RAGNA_ORC_HEAD, RAGNA_CHIEF_NOTICE, IMMORTAL_FLAME
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        give_items(pc, ORDEAL_NECKLACE, 1)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 92)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30565-05b.htm"
        else
          html = "30565-05.htm"
        end
      end
    when "30565-05a.html", "30558-03a.html", "30643-02.html", "30643-03.html", "30649-02.html", "30649-03.html"
      html = event
    when "30565-08.html"
      if has_quest_items?(pc, HUGE_ORC_FANG)
        take_items(pc, ORDEAL_NECKLACE, 1)
        take_items(pc, HUGE_ORC_FANG, 1)
        take_items(pc, SWORD_INTO_SKULL, 1)
        take_items(pc, AXE_OF_CEREMONY, 1)
        take_items(pc, HANDIWORK_SPIDER_BROOCH, 1)
        take_items(pc, MONSTER_EYE_WOODCARVING, 1)
        give_items(pc, BEAR_FANG_NECKLACE, 1)
        qs.set_cond(3, true)
        html = event
      end
    when "30558-02.html"
      if get_quest_items_count(pc, ADENA) >= 1000
        take_items(pc, ADENA, 1000)
        give_items(pc, NERUGA_AXE_BLADE, 1)
        html = event
      end
    when "30566-02.html"
      give_items(pc, VARKEES_CHARM, 1)
      html = event
    when "30567-02.html"
      give_items(pc, TANTUS_CHARM, 1)
      html = event
    when "30568-02.html"
      give_items(pc, HATOS_CHARM, 1)
      html = event
    when "30641-02.html"
      give_items(pc, TAKUNA_CHARM, 1)
      html = event
    when "30642-02.html"
      give_items(pc, CHIANTA_CHARM, 1)
      html = event
    when "30649-04.html"
      if has_quest_items?(pc, BEAR_FANG_NECKLACE)
        take_items(pc, BEAR_FANG_NECKLACE, 1)
        give_items(pc, MARTANKUS_CHARM, 1)
        qs.set_cond(4, true)
        html = event
      end
    when "30649-07.html"
      npc = npc.not_nil!
      if npc.summoned_npc_count < 1
        add_spawn(npc, FIRST_ORC, FIRST_ORC_SPAWN, false, 10000)
      end
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
      when MARSH_SPIDER
        if has_quest_items?(killer, ORDEAL_NECKLACE, TAKUNA_CHARM)
          unless has_quest_items?(killer, HANDIWORK_SPIDER_BROOCH)
            if get_quest_items_count(killer, MARSH_SPIDER_FEELER) < 10
              give_items(killer, MARSH_SPIDER_FEELER, 2)
              if get_quest_items_count(killer, MARSH_SPIDER_FEELER) >= 10
                play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              else
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            elsif get_quest_items_count(killer, MARSH_SPIDER_FEET) < 10
              give_items(killer, MARSH_SPIDER_FEET, 2)
              if get_quest_items_count(killer, MARSH_SPIDER_FEET) >= 10
                play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              else
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            end
          end
        end
      when BREKA_ORC_SHAMAN, BREKA_ORC_OVERLORD
        if has_quest_items?(killer, ORDEAL_NECKLACE, VARKEES_CHARM, MANAKIAS_ORDERS)
          unless has_at_least_one_quest_item?(killer, HUGE_ORC_FANG, MANAKIAS_AMULET)
            if get_quest_items_count(killer, BREKA_ORC_FANG) < 20
              give_items(killer, BREKA_ORC_FANG, 2)
              if get_quest_items_count(killer, BREKA_ORC_FANG) >= 20
                play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              else
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            end
          end
        end
      when ENCHANTED_MONSTEREYE
        if has_quest_items?(killer, ORDEAL_NECKLACE, CHIANTA_CHARM)
          unless has_quest_items?(killer, MONSTER_EYE_WOODCARVING)
            if get_quest_items_count(killer, ENCHANTED_MONSTER_CORNEA) < 20
              give_items(killer, ENCHANTED_MONSTER_CORNEA, 1)
              if get_quest_items_count(killer, ENCHANTED_MONSTER_CORNEA) >= 20
                play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              else
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            end
          end
        end
      when TIMAK_ORC, TIMAK_ORC_ARCHER, TIMAK_ORC_SOLDIER, TIMAK_ORC_WARRIOR,
           TIMAK_ORC_SHAMAN, TIMAK_ORC_OVERLORD
        if has_quest_items?(killer, ORDEAL_NECKLACE, HATOS_CHARM)
          unless has_quest_items?(killer, SWORD_INTO_SKULL)
            if get_quest_items_count(killer, TIMAK_ORC_SKULL) < 10
              give_items(killer, TIMAK_ORC_SKULL, 1)
              if get_quest_items_count(killer, TIMAK_ORC_SKULL) >= 10
                play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              else
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            end
          end
        end
      when RAGNA_ORC_OVERLORD, RAGNA_ORC_SEER
        if has_quest_items?(killer, MARTANKUS_CHARM)
          if !has_quest_items?(killer, RAGNA_CHIEF_NOTICE)
            give_items(killer, RAGNA_CHIEF_NOTICE, 1)
            play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
          elsif !has_quest_items?(killer, RAGNA_ORC_HEAD)
            give_items(killer, RAGNA_ORC_HEAD, 1)
            qs.set_cond(5, true)
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
      if npc.id == FLAME_LORD_KAKAI
        if !pc.race.orc?
          html = "30565-01.html"
        elsif !pc.class_id.orc_shaman?
          html = "30565-02.html"
        elsif pc.level < MIN_LEVEL
          html = "30565-03.html"
        else
          html = "30565-04.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when FLAME_LORD_KAKAI
        if has_quest_items?(pc, ORDEAL_NECKLACE)
          if has_quest_items?(pc, HUGE_ORC_FANG, SWORD_INTO_SKULL, AXE_OF_CEREMONY, MONSTER_EYE_WOODCARVING, HANDIWORK_SPIDER_BROOCH)
            html = "30565-07.html"
          else
            html = "30565-06.html"
          end
        elsif has_quest_items?(pc, BEAR_FANG_NECKLACE)
          html = "30565-09.html"
        elsif has_quest_items?(pc, MARTANKUS_CHARM)
          html = "30565-10.html"
        elsif has_quest_items?(pc, IMMORTAL_FLAME)
          give_adena(pc, 161806, true)
          give_items(pc, MARK_OF_LORD, 1)
          add_exp_and_sp(pc, 894888, 61408)
          qs.exit_quest(false, true)
          pc.send_packet(SocialAction.new(pc.l2id, 3))
          html = "30565-11.html"
        end
      when SEER_SOMAK
        if has_quest_items?(pc, ORDEAL_NECKLACE, HATOS_CHARM, SUMARIS_LETTER) && !has_at_least_one_quest_item?(pc, SWORD_INTO_SKULL, URUTU_BLADE)
          take_items(pc, SUMARIS_LETTER, 1)
          give_items(pc, URUTU_BLADE, 1)
          html = "30510-01.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, HATOS_CHARM, URUTU_BLADE) && !has_at_least_one_quest_item?(pc, SWORD_INTO_SKULL, SUMARIS_LETTER)
          html = "30510-02.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, SWORD_INTO_SKULL) && !has_at_least_one_quest_item?(pc, HATOS_CHARM, URUTU_BLADE, SUMARIS_LETTER)
          html = "30510-03.html"
        end
      when SEER_MANAKIA
        if has_quest_items?(pc, ORDEAL_NECKLACE, VARKEES_CHARM) && !has_at_least_one_quest_item?(pc, HUGE_ORC_FANG, MANAKIAS_AMULET, MANAKIAS_ORDERS)
          give_items(pc, MANAKIAS_ORDERS, 1)
          html = "30515-01.html"
        elsif has_quest_items?(pc, VARKEES_CHARM, ORDEAL_NECKLACE, MANAKIAS_ORDERS) && !has_at_least_one_quest_item?(pc, HUGE_ORC_FANG, MANAKIAS_AMULET)
          if get_quest_items_count(pc, BREKA_ORC_FANG) < 20
            html = "30515-02.html"
          else
            take_items(pc, MANAKIAS_ORDERS, 1)
            take_items(pc, BREKA_ORC_FANG, -1)
            give_items(pc, MANAKIAS_AMULET, 1)
            html = "30515-03.html"
          end
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, VARKEES_CHARM, MANAKIAS_AMULET) && !has_at_least_one_quest_item?(pc, HUGE_ORC_FANG, MANAKIAS_ORDERS)
          html = "30515-04.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, HUGE_ORC_FANG) && !has_at_least_one_quest_item?(pc, VARKEES_CHARM, MANAKIAS_AMULET, MANAKIAS_ORDERS)
          html = "30515-05.html"
        end
      when TRADER_JAKAL
        if has_quest_items?(pc, ORDEAL_NECKLACE, TANTUS_CHARM) && !has_at_least_one_quest_item?(pc, AXE_OF_CEREMONY, NERUGA_AXE_BLADE)
          if get_quest_items_count(pc, ADENA) >= 1000
            html = "30558-01.html"
          else
            html = "30558-03.html"
          end
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, TANTUS_CHARM, NERUGA_AXE_BLADE) && !has_quest_items?(pc, AXE_OF_CEREMONY)
          html = "30558-04.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, AXE_OF_CEREMONY) && !has_quest_items?(pc, TANTUS_CHARM)
          html = "30558-05.html"
        end
      when BLACKSMITH_SUMARI
        if has_quest_items?(pc, HATOS_CHARM, ORDEAL_NECKLACE) && !has_at_least_one_quest_item?(pc, SWORD_INTO_SKULL, URUTU_BLADE, SUMARIS_LETTER)
          give_items(pc, SUMARIS_LETTER, 1)
          html = "30564-01.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, HATOS_CHARM, SUMARIS_LETTER) && !has_at_least_one_quest_item?(pc, SWORD_INTO_SKULL, URUTU_BLADE)
          html = "30564-02.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, HATOS_CHARM, URUTU_BLADE) && !has_at_least_one_quest_item?(pc, SUMARIS_LETTER, SWORD_INTO_SKULL)
          html = "30564-03.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, SWORD_INTO_SKULL) && !has_at_least_one_quest_item?(pc, HATOS_CHARM, URUTU_BLADE, SUMARIS_LETTER)
          html = "30564-04.html"
        end
      when ATUBA_CHIEF_VARKEES
        if has_quest_items?(pc, ORDEAL_NECKLACE) && !has_at_least_one_quest_item?(pc, HUGE_ORC_FANG, VARKEES_CHARM)
          html = "30566-01.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, VARKEES_CHARM) && !has_at_least_one_quest_item?(pc, HUGE_ORC_FANG, MANAKIAS_AMULET)
          html = "30566-03.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, VARKEES_CHARM, MANAKIAS_AMULET) && !has_quest_items?(pc, HUGE_ORC_FANG)
          take_items(pc, VARKEES_CHARM, 1)
          take_items(pc, MANAKIAS_AMULET, 1)
          give_items(pc, HUGE_ORC_FANG, 1)
          if has_quest_items?(pc, AXE_OF_CEREMONY, SWORD_INTO_SKULL, HANDIWORK_SPIDER_BROOCH, MONSTER_EYE_WOODCARVING)
            qs.set_cond(2, true)
          end
          html = "30566-04.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, HUGE_ORC_FANG) && !has_quest_items?(pc, VARKEES_CHARM)
          html = "30566-05.html"
        end
      when NERUGA_CHIEF_TANTUS
        if has_quest_items?(pc, ORDEAL_NECKLACE) && !has_at_least_one_quest_item?(pc, AXE_OF_CEREMONY, TANTUS_CHARM)
          html = "30567-01.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, TANTUS_CHARM) && !has_quest_items?(pc, AXE_OF_CEREMONY)
          if !has_quest_items?(pc, NERUGA_AXE_BLADE) || get_quest_items_count(pc, BONE_ARROW) < 1000
            html = "30567-03.html"
          else
            take_items(pc, BONE_ARROW, 1000)
            take_items(pc, TANTUS_CHARM, 1)
            take_items(pc, NERUGA_AXE_BLADE, 1)
            give_items(pc, AXE_OF_CEREMONY, 1)
            if has_quest_items?(pc, HUGE_ORC_FANG, SWORD_INTO_SKULL, HANDIWORK_SPIDER_BROOCH, MONSTER_EYE_WOODCARVING)
              qs.set_cond(2, true)
            end
            html = "30567-04.html"
          end
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, AXE_OF_CEREMONY) && !has_quest_items?(pc, TANTUS_CHARM)
          html = "30567-05.html"
        end
      when URUTU_CHIEF_HATOS
        if has_quest_items?(pc, ORDEAL_NECKLACE) && !has_at_least_one_quest_item?(pc, SWORD_INTO_SKULL, HATOS_CHARM)
          html = "30568-01.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, HATOS_CHARM) && !has_quest_items?(pc, SWORD_INTO_SKULL)
          if has_quest_items?(pc, URUTU_BLADE) && get_quest_items_count(pc, TIMAK_ORC_SKULL) >= 10
            take_items(pc, HATOS_CHARM, 1)
            take_items(pc, URUTU_BLADE, 1)
            take_items(pc, TIMAK_ORC_SKULL, -1)
            give_items(pc, SWORD_INTO_SKULL, 1)
            if has_quest_items?(pc, HUGE_ORC_FANG, AXE_OF_CEREMONY, HANDIWORK_SPIDER_BROOCH, MONSTER_EYE_WOODCARVING)
              qs.set_cond(2, true)
            end
            html = "30568-04.html"
          else
            html = "30568-03.html"
          end
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, SWORD_INTO_SKULL) && !has_quest_items?(pc, HATOS_CHARM)
          html = "30568-05.html"
        end
      when DUDA_MARA_CHIEF_TAKUNA
        if has_quest_items?(pc, ORDEAL_NECKLACE) && !has_at_least_one_quest_item?(pc, HANDIWORK_SPIDER_BROOCH, TAKUNA_CHARM)
          html = "30641-01.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, TAKUNA_CHARM) && !has_quest_items?(pc, HANDIWORK_SPIDER_BROOCH)
          if (get_quest_items_count(pc, MARSH_SPIDER_FEELER) >= 10) && get_quest_items_count(pc, MARSH_SPIDER_FEET) >= 10
            take_items(pc, TAKUNA_CHARM, 1)
            take_items(pc, MARSH_SPIDER_FEELER, -1)
            take_items(pc, MARSH_SPIDER_FEET, -1)
            give_items(pc, HANDIWORK_SPIDER_BROOCH, 1)
            if has_quest_items?(pc, HUGE_ORC_FANG, AXE_OF_CEREMONY, SWORD_INTO_SKULL, MONSTER_EYE_WOODCARVING)
              qs.set_cond(2, true)
            end
            html = "30641-04.html"
          else
            html = "30641-03.html"
          end
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, HANDIWORK_SPIDER_BROOCH) && !has_quest_items?(pc, TAKUNA_CHARM)
          html = "30641-05.html"
        end
      when GANDI_CHIEF_CHIANTA
        if has_quest_items?(pc, ORDEAL_NECKLACE) && !has_at_least_one_quest_item?(pc, MONSTER_EYE_WOODCARVING, CHIANTA_CHARM)
          html = "30642-01.html"
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, CHIANTA_CHARM) && !has_quest_items?(pc, MONSTER_EYE_WOODCARVING)
          if get_quest_items_count(pc, ENCHANTED_MONSTER_CORNEA) < 20
            html = "30642-03.html"
          else
            take_items(pc, CHIANTA_CHARM, 1)
            take_items(pc, ENCHANTED_MONSTER_CORNEA, -1)
            give_items(pc, MONSTER_EYE_WOODCARVING, 1)
            if has_quest_items?(pc, HUGE_ORC_FANG, AXE_OF_CEREMONY, SWORD_INTO_SKULL, HANDIWORK_SPIDER_BROOCH)
              qs.set_cond(2, true)
            end
            html = "30642-04.html"
          end
        elsif has_quest_items?(pc, ORDEAL_NECKLACE, MONSTER_EYE_WOODCARVING) && !has_quest_items?(pc, CHIANTA_CHARM)
          html = "30642-05.html"
        end
      when FIRST_ORC
        if has_at_least_one_quest_item?(pc, MARTANKUS_CHARM, IMMORTAL_FLAME)
          qs.set_cond(7, true)
          html = "30643-01.html"
        end
      when ANCESTOR_MARTANKUS
        if has_quest_items?(pc, BEAR_FANG_NECKLACE)
          html = "30649-01.html"
        elsif has_quest_items?(pc, MARTANKUS_CHARM) && !has_at_least_one_quest_item?(pc, RAGNA_CHIEF_NOTICE, RAGNA_ORC_HEAD)
          html = "30649-05.html"
        elsif has_quest_items?(pc, MARTANKUS_CHARM, RAGNA_CHIEF_NOTICE, RAGNA_ORC_HEAD)
          take_items(pc, MARTANKUS_CHARM, 1)
          take_items(pc, RAGNA_ORC_HEAD, 1)
          take_items(pc, RAGNA_CHIEF_NOTICE, 1)
          give_items(pc, IMMORTAL_FLAME, 1)
          qs.set_cond(6, true)
          html = "30649-06.html"
        elsif has_quest_items?(pc, IMMORTAL_FLAME)
          if npc.summoned_npc_count < 1
            add_spawn(npc, FIRST_ORC, FIRST_ORC_SPAWN, false, 10000)
          end
          html = "30649-08.html"
        end
      else
        # [automatically added else]
      end

    elsif qs.completed?
      if npc.id == FLAME_LORD_KAKAI
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
