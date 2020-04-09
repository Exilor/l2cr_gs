class Scripts::Q00330_AdeptOfTaste < Quest
  # NPCs
  private ACCESSORY_MERCHANT_SONIA = 30062
  private PRIESTESS_GLYVKA = 30067
  private MAGISTER_ROLLANT = 30069
  private GUARD_JACOB = 30073
  private GROCER_PANO = 30078
  private MAGISTER_MIRIEN = 30461
  private JONAS = 30469
  # Items
  private INGREDIENT_LIST = 1420
  private SONIAS_BOTANY_BOOK = 1421
  private RED_MANDRAGORA_ROOT = 1422
  private WHITE_MANDRAGORA_ROOT = 1423
  private RED_MANDRAGORA_SAP = 1424
  private WHITE_MANDRAGORA_SAP = 1425
  private JACOBS_INSECT_BOOK = 1426
  private NECTAR = 1427
  private ROYAL_JELLY = 1428
  private HONEY = 1429
  private GOLDEN_HONEY = 1430
  private PANOS_CONTRACT = 1431
  private HOBGOBLIN_AMULET = 1432
  private DIONIAN_POTATO = 1433
  private GLYVKAS_BOTANY_BOOK = 1434
  private GREEN_MARSH_MOSS = 1435
  private BROWN_MARSH_MOSS = 1436
  private GREEN_MOSS_BUNDLE = 1437
  private BROWN_MOSS_BUNDLE = 1438
  private ROLLANTS_CREATURE_BOOK = 1439
  private BODY_OF_MONSTER_EYE = 1440
  private MONSTER_EYE_MEAT = 1441
  private JONASS_1ST_STEAK_DISH = 1442
  private JONASS_2ND_STEAK_DISH = 1443
  private JONASS_3RD_STEAK_DISH = 1444
  private JONASS_4TH_STEAK_DISH = 1445
  private JONASS_5TH_STEAK_DISH = 1446
  private MIRIENS_REVIEW_1 = 1447
  private MIRIENS_REVIEW_2 = 1448
  private MIRIENS_REVIEW_3 = 1449
  private MIRIENS_REVIEW_4 = 1450
  private MIRIENS_REVIEW_5 = 1451
  # Reward
  private JONASS_SALAD_RECIPE = 1455
  private JONASS_SAUCE_RECIPE = 1456
  private JONASS_STEAK_RECIPE = 1457
  # Monster
  private HOBGOBLIN = 20147
  private MANDRAGORA_SPROUT1 = 20154
  private MANDRAGORA_SAPLING = 20155
  private MANDRAGORA_BLOSSOM = 20156
  private BLOODY_BEE = 20204
  private MANDRAGORA_SPROUT2 = 20223
  private GRAY_ANT = 20226
  private GIANT_CRIMSON_ANT = 20228
  private STINGER_WASP = 20229
  private MONSTER_EYE_SEARCHER = 20265
  private MONSTER_EYE_GAZER = 20266
  # Misc
  private MIN_LEVEL = 24

  def initialize
    super(330, self.class.simple_name, "Adept Of Taste")

    add_start_npc(JONAS)
    add_talk_id(
      JONAS, ACCESSORY_MERCHANT_SONIA, PRIESTESS_GLYVKA, MAGISTER_ROLLANT,
      GUARD_JACOB, GROCER_PANO, MAGISTER_MIRIEN
    )
    add_kill_id(
      HOBGOBLIN, MANDRAGORA_SPROUT1, MANDRAGORA_SAPLING, MANDRAGORA_BLOSSOM,
      BLOODY_BEE, MANDRAGORA_SPROUT2, GRAY_ANT, GIANT_CRIMSON_ANT, STINGER_WASP,
      MONSTER_EYE_SEARCHER, MONSTER_EYE_GAZER
    )
    register_quest_items(
      INGREDIENT_LIST, SONIAS_BOTANY_BOOK, RED_MANDRAGORA_ROOT,
      WHITE_MANDRAGORA_ROOT, RED_MANDRAGORA_SAP, WHITE_MANDRAGORA_SAP,
      JACOBS_INSECT_BOOK, NECTAR, ROYAL_JELLY, HONEY, GOLDEN_HONEY,
      PANOS_CONTRACT, HOBGOBLIN_AMULET, DIONIAN_POTATO, GLYVKAS_BOTANY_BOOK,
      GREEN_MARSH_MOSS, BROWN_MARSH_MOSS, GREEN_MOSS_BUNDLE, BROWN_MOSS_BUNDLE,
      ROLLANTS_CREATURE_BOOK, BODY_OF_MONSTER_EYE, MONSTER_EYE_MEAT,
      JONASS_1ST_STEAK_DISH, JONASS_2ND_STEAK_DISH, JONASS_3RD_STEAK_DISH,
      JONASS_4TH_STEAK_DISH, JONASS_5TH_STEAK_DISH, MIRIENS_REVIEW_1,
      MIRIENS_REVIEW_2, MIRIENS_REVIEW_3, MIRIENS_REVIEW_4, MIRIENS_REVIEW_5
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    unless qs = get_quest_state(pc, false)
      return
    end

    case event
    when "30469-03.htm"
      if qs.created?
        qs.start_quest
        give_items(pc, INGREDIENT_LIST, 1)
        html = event
      end
    when "30062-05.html"
      if has_quest_items?(pc, SONIAS_BOTANY_BOOK)
        if get_quest_items_count(pc, RED_MANDRAGORA_ROOT) + get_quest_items_count(pc, WHITE_MANDRAGORA_ROOT) >= 40
          if get_quest_items_count(pc, WHITE_MANDRAGORA_ROOT) < 40
            take_items(pc, SONIAS_BOTANY_BOOK, 1)
            take_items(pc, RED_MANDRAGORA_ROOT, -1)
            take_items(pc, WHITE_MANDRAGORA_ROOT, -1)
            give_items(pc, RED_MANDRAGORA_SAP, 1)
            html = event
          end
        end
      end
    when "30067-05.html"
      if has_quest_items?(pc, GLYVKAS_BOTANY_BOOK) && get_quest_items_count(pc, GREEN_MARSH_MOSS) + get_quest_items_count(pc, BROWN_MARSH_MOSS) >= 20
        if get_quest_items_count(pc, BROWN_MARSH_MOSS) < 20
          take_items(pc, GLYVKAS_BOTANY_BOOK, 1)
          take_items(pc, GREEN_MARSH_MOSS, -1)
          take_items(pc, BROWN_MARSH_MOSS, -1)
          give_items(pc, GREEN_MOSS_BUNDLE, 1)
          html = event
        end
      end
    when "30073-05.html"
      if has_quest_items?(pc, JACOBS_INSECT_BOOK) && get_quest_items_count(pc, NECTAR) >= 20 && get_quest_items_count(pc, ROYAL_JELLY) < 10
        take_items(pc, JACOBS_INSECT_BOOK, 1)
        take_items(pc, NECTAR, -1)
        take_items(pc, ROYAL_JELLY, -1)
        give_items(pc, HONEY, 1)
        html = event
      end
    when "30062-04.html", "30067-04.html", "30073-04.html", "30469-04.html",
         "30469-04t1.html", "30469-04t2.html", "30469-04t3.html",
         "30469-04t4.html", "30469-04t5.html"
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
      when HOBGOBLIN
        if get_quest_items_count(killer, RED_MANDRAGORA_SAP) + get_quest_items_count(killer, WHITE_MANDRAGORA_SAP) + get_quest_items_count(killer, HONEY) + get_quest_items_count(killer, GOLDEN_HONEY) + get_quest_items_count(killer, DIONIAN_POTATO) + get_quest_items_count(killer, GREEN_MOSS_BUNDLE) + get_quest_items_count(killer, BROWN_MOSS_BUNDLE) + get_quest_items_count(killer, MONSTER_EYE_MEAT) < 5
          if has_quest_items?(killer, INGREDIENT_LIST, PANOS_CONTRACT) && get_quest_items_count(killer, HOBGOBLIN_AMULET) < 30
            give_items(killer, HOBGOBLIN_AMULET, 1)
            if get_quest_items_count(killer, HOBGOBLIN_AMULET) == 30
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when MANDRAGORA_SPROUT1, MANDRAGORA_SPROUT2
        if get_quest_items_count(killer, RED_MANDRAGORA_SAP) + get_quest_items_count(killer, WHITE_MANDRAGORA_SAP) + get_quest_items_count(killer, HONEY) + get_quest_items_count(killer, GOLDEN_HONEY) + get_quest_items_count(killer, DIONIAN_POTATO) + get_quest_items_count(killer, GREEN_MOSS_BUNDLE) + get_quest_items_count(killer, BROWN_MOSS_BUNDLE) + get_quest_items_count(killer, MONSTER_EYE_MEAT) < 5
          if has_quest_items?(killer, INGREDIENT_LIST, SONIAS_BOTANY_BOOK) && !has_at_least_one_quest_item?(killer, RED_MANDRAGORA_SAP, WHITE_MANDRAGORA_SAP)
            i0 = Rnd.rand(100)
            if i0 < 70
              if get_quest_items_count(killer, RED_MANDRAGORA_ROOT) < 40
                give_items(killer, RED_MANDRAGORA_ROOT, 1)
                if get_quest_items_count(killer, RED_MANDRAGORA_ROOT) == 40
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            elsif i0 < 77
              if get_quest_items_count(killer, WHITE_MANDRAGORA_ROOT) < 40
                give_items(killer, WHITE_MANDRAGORA_ROOT, 1)
                if get_quest_items_count(killer, WHITE_MANDRAGORA_ROOT) == 40
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            end
          end
        end
      when MANDRAGORA_SAPLING
        if get_quest_items_count(killer, RED_MANDRAGORA_SAP) + get_quest_items_count(killer, WHITE_MANDRAGORA_SAP) + get_quest_items_count(killer, HONEY) + get_quest_items_count(killer, GOLDEN_HONEY) + get_quest_items_count(killer, DIONIAN_POTATO) + get_quest_items_count(killer, GREEN_MOSS_BUNDLE) + get_quest_items_count(killer, BROWN_MOSS_BUNDLE) + get_quest_items_count(killer, MONSTER_EYE_MEAT) < 5
          if has_quest_items?(killer, INGREDIENT_LIST, SONIAS_BOTANY_BOOK) && !has_at_least_one_quest_item?(killer, RED_MANDRAGORA_SAP, WHITE_MANDRAGORA_SAP)
            i0 = Rnd.rand(100)
            if i0 < 77
              if get_quest_items_count(killer, RED_MANDRAGORA_ROOT) < 40
                give_items(killer, RED_MANDRAGORA_ROOT, 1)
                if get_quest_items_count(killer, RED_MANDRAGORA_ROOT) == 40
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            elsif i0 < 85
              if get_quest_items_count(killer, WHITE_MANDRAGORA_ROOT) < 40
                give_items(killer, WHITE_MANDRAGORA_ROOT, 1)
                if get_quest_items_count(killer, WHITE_MANDRAGORA_ROOT) == 40
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            end
          end
        end
      when MANDRAGORA_BLOSSOM
        if get_quest_items_count(killer, RED_MANDRAGORA_SAP) + get_quest_items_count(killer, WHITE_MANDRAGORA_SAP) + get_quest_items_count(killer, HONEY) + get_quest_items_count(killer, GOLDEN_HONEY) + get_quest_items_count(killer, DIONIAN_POTATO) + get_quest_items_count(killer, GREEN_MOSS_BUNDLE) + get_quest_items_count(killer, BROWN_MOSS_BUNDLE) + get_quest_items_count(killer, MONSTER_EYE_MEAT) < 5
          if has_quest_items?(killer, INGREDIENT_LIST, SONIAS_BOTANY_BOOK) && !has_at_least_one_quest_item?(killer, RED_MANDRAGORA_SAP, WHITE_MANDRAGORA_SAP)
            i0 = Rnd.rand(100)
            if i0 < 87
              if get_quest_items_count(killer, RED_MANDRAGORA_ROOT) < 40
                give_items(killer, RED_MANDRAGORA_ROOT, 1)
                if get_quest_items_count(killer, RED_MANDRAGORA_ROOT) == 40
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            elsif i0 < 96
              if get_quest_items_count(killer, WHITE_MANDRAGORA_ROOT) < 40
                give_items(killer, WHITE_MANDRAGORA_ROOT, 1)
                if get_quest_items_count(killer, WHITE_MANDRAGORA_ROOT) == 40
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            end
          end
        end
      when BLOODY_BEE
        if get_quest_items_count(killer, RED_MANDRAGORA_SAP) + get_quest_items_count(killer, WHITE_MANDRAGORA_SAP) + get_quest_items_count(killer, HONEY) + get_quest_items_count(killer, GOLDEN_HONEY) + get_quest_items_count(killer, DIONIAN_POTATO) + get_quest_items_count(killer, GREEN_MOSS_BUNDLE) + get_quest_items_count(killer, BROWN_MOSS_BUNDLE) + get_quest_items_count(killer, MONSTER_EYE_MEAT) < 5
          if has_quest_items?(killer, INGREDIENT_LIST, JACOBS_INSECT_BOOK)
            i0 = Rnd.rand(100)
            if i0 < 80
              if get_quest_items_count(killer, NECTAR) < 20
                give_items(killer, NECTAR, 1)
                if get_quest_items_count(killer, NECTAR) == 20
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            elsif i0 < 95
              if get_quest_items_count(killer, ROYAL_JELLY) < 10
                give_items(killer, ROYAL_JELLY, 1)
                if get_quest_items_count(killer, ROYAL_JELLY) == 10
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            end
          end
        end
      when GRAY_ANT
        if get_quest_items_count(killer, RED_MANDRAGORA_SAP) + get_quest_items_count(killer, WHITE_MANDRAGORA_SAP) + get_quest_items_count(killer, HONEY) + get_quest_items_count(killer, GOLDEN_HONEY) + get_quest_items_count(killer, DIONIAN_POTATO) + get_quest_items_count(killer, GREEN_MOSS_BUNDLE) + get_quest_items_count(killer, BROWN_MOSS_BUNDLE) + get_quest_items_count(killer, MONSTER_EYE_MEAT) < 5
          if has_quest_items?(killer, INGREDIENT_LIST, GLYVKAS_BOTANY_BOOK)
            i0 = Rnd.rand(100)
            if i0 < 87
              if get_quest_items_count(killer, GREEN_MARSH_MOSS) < 20
                give_items(killer, GREEN_MARSH_MOSS, 1)
                if get_quest_items_count(killer, GREEN_MARSH_MOSS) == 20
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            elsif i0 < 96
              if get_quest_items_count(killer, BROWN_MARSH_MOSS) < 20
                give_items(killer, BROWN_MARSH_MOSS, 1)
                if get_quest_items_count(killer, BROWN_MARSH_MOSS) == 20
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            end
          end
        end
      when GIANT_CRIMSON_ANT
        if get_quest_items_count(killer, RED_MANDRAGORA_SAP) + get_quest_items_count(killer, WHITE_MANDRAGORA_SAP) + get_quest_items_count(killer, HONEY) + get_quest_items_count(killer, GOLDEN_HONEY) + get_quest_items_count(killer, DIONIAN_POTATO) + get_quest_items_count(killer, GREEN_MOSS_BUNDLE) + get_quest_items_count(killer, BROWN_MOSS_BUNDLE) + get_quest_items_count(killer, MONSTER_EYE_MEAT) < 5
          if has_quest_items?(killer, INGREDIENT_LIST, GLYVKAS_BOTANY_BOOK)
            i0 = Rnd.rand(100)
            if i0 < 90
              if get_quest_items_count(killer, GREEN_MARSH_MOSS) < 20
                give_items(killer, GREEN_MARSH_MOSS, 1)
                if get_quest_items_count(killer, GREEN_MARSH_MOSS) == 20
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            else
              if get_quest_items_count(killer, BROWN_MARSH_MOSS) < 20
                give_items(killer, BROWN_MARSH_MOSS, 1)
                if get_quest_items_count(killer, BROWN_MARSH_MOSS) == 20
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            end
          end
        end
      when STINGER_WASP
        if get_quest_items_count(killer, RED_MANDRAGORA_SAP) + get_quest_items_count(killer, WHITE_MANDRAGORA_SAP) + get_quest_items_count(killer, HONEY) + get_quest_items_count(killer, GOLDEN_HONEY) + get_quest_items_count(killer, DIONIAN_POTATO) + get_quest_items_count(killer, GREEN_MOSS_BUNDLE) + get_quest_items_count(killer, BROWN_MOSS_BUNDLE) + get_quest_items_count(killer, MONSTER_EYE_MEAT) < 5
          if has_quest_items?(killer, INGREDIENT_LIST, JACOBS_INSECT_BOOK)
            i0 = Rnd.rand(100)
            if i0 < 92
              if get_quest_items_count(killer, NECTAR) < 20
                give_items(killer, NECTAR, 1)
                if get_quest_items_count(killer, NECTAR) == 20
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            else
              if get_quest_items_count(killer, ROYAL_JELLY) < 10
                give_items(killer, ROYAL_JELLY, 1)
                if get_quest_items_count(killer, ROYAL_JELLY) == 10
                  play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
                else
                  play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
                end
              end
            end
          end
        end
      when MONSTER_EYE_SEARCHER
        if get_quest_items_count(killer, RED_MANDRAGORA_SAP) + get_quest_items_count(killer, WHITE_MANDRAGORA_SAP) + get_quest_items_count(killer, HONEY) + get_quest_items_count(killer, GOLDEN_HONEY) + get_quest_items_count(killer, DIONIAN_POTATO) + get_quest_items_count(killer, GREEN_MOSS_BUNDLE) + get_quest_items_count(killer, BROWN_MOSS_BUNDLE) + get_quest_items_count(killer, MONSTER_EYE_MEAT) < 5
          if has_quest_items?(killer, INGREDIENT_LIST, ROLLANTS_CREATURE_BOOK) && get_quest_items_count(killer, BODY_OF_MONSTER_EYE) < 30
            i0 = Rnd.rand(100)
            if i0 < 77
              if get_quest_items_count(killer, BODY_OF_MONSTER_EYE) == 29
                give_items(killer, BODY_OF_MONSTER_EYE, 1)
                play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              else
                give_items(killer, BODY_OF_MONSTER_EYE, 2)
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            elsif i0 < 97
              if get_quest_items_count(killer, BROWN_MARSH_MOSS) == 28
                give_items(killer, BODY_OF_MONSTER_EYE, 2)
                play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              elsif get_quest_items_count(killer, BROWN_MARSH_MOSS) == 29
                give_items(killer, BODY_OF_MONSTER_EYE, 1)
                play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              else
                give_items(killer, BODY_OF_MONSTER_EYE, 3)
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end

            end
          end
        end
      when MONSTER_EYE_GAZER
        if get_quest_items_count(killer, RED_MANDRAGORA_SAP) + get_quest_items_count(killer, WHITE_MANDRAGORA_SAP) + get_quest_items_count(killer, HONEY) + get_quest_items_count(killer, GOLDEN_HONEY) + get_quest_items_count(killer, DIONIAN_POTATO) + get_quest_items_count(killer, GREEN_MOSS_BUNDLE) + get_quest_items_count(killer, BROWN_MOSS_BUNDLE) + get_quest_items_count(killer, MONSTER_EYE_MEAT) < 5
          if has_quest_items?(killer, INGREDIENT_LIST, ROLLANTS_CREATURE_BOOK) && get_quest_items_count(killer, BODY_OF_MONSTER_EYE) < 30
            if Rnd.rand(10) < 7
              give_items(killer, BODY_OF_MONSTER_EYE, 1)
              if get_quest_items_count(killer, BODY_OF_MONSTER_EYE) == 30
                play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              else
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            else
              if get_quest_items_count(killer, BROWN_MARSH_MOSS) == 29
                give_items(killer, BODY_OF_MONSTER_EYE, 1)
                play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              else
                give_items(killer, BODY_OF_MONSTER_EYE, 2)
                play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
              end
            end
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
      if npc.id == JONAS
        if pc.level < MIN_LEVEL
          html = "30469-01.htm"
        else
          html = "30469-02.htm"
        end
      end
    elsif qs.started?
      case npc.id
      when JONAS
        if has_quest_items?(pc, INGREDIENT_LIST)
          if get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5
            html = "30469-04.html"
          else
            if get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) == 0
              if Rnd.rand(10) < 5
                take_items(pc, INGREDIENT_LIST, -1)
                take_items(pc, RED_MANDRAGORA_SAP, -1)
                take_items(pc, WHITE_MANDRAGORA_SAP, -1)
                take_items(pc, HONEY, -1)
                take_items(pc, GOLDEN_HONEY, -1)
                take_items(pc, DIONIAN_POTATO, -1)
                take_items(pc, GREEN_MOSS_BUNDLE, -1)
                take_items(pc, BROWN_MOSS_BUNDLE, -1)
                take_items(pc, MONSTER_EYE_MEAT, -1)
                give_items(pc, JONASS_2ND_STEAK_DISH, 1)
                html = "30469-05t2.html"
              else
                take_items(pc, INGREDIENT_LIST, -1)
                take_items(pc, RED_MANDRAGORA_SAP, -1)
                take_items(pc, WHITE_MANDRAGORA_SAP, -1)
                take_items(pc, HONEY, -1)
                take_items(pc, GOLDEN_HONEY, -1)
                take_items(pc, DIONIAN_POTATO, -1)
                take_items(pc, GREEN_MOSS_BUNDLE, -1)
                take_items(pc, BROWN_MOSS_BUNDLE, -1)
                take_items(pc, MONSTER_EYE_MEAT, -1)
                give_items(pc, JONASS_1ST_STEAK_DISH, 1)
                html = "30469-05t1.html"
              end
            end

            if get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) == 1
              if Rnd.rand(10) < 5
                take_items(pc, INGREDIENT_LIST, -1)
                take_items(pc, RED_MANDRAGORA_SAP, -1)
                take_items(pc, WHITE_MANDRAGORA_SAP, -1)
                take_items(pc, HONEY, -1)
                take_items(pc, GOLDEN_HONEY, -1)
                take_items(pc, DIONIAN_POTATO, -1)
                take_items(pc, GREEN_MOSS_BUNDLE, -1)
                take_items(pc, BROWN_MOSS_BUNDLE, -1)
                take_items(pc, MONSTER_EYE_MEAT, -1)
                give_items(pc, JONASS_3RD_STEAK_DISH, 1)
                html = "30469-05t3.html"
              else
                take_items(pc, INGREDIENT_LIST, -1)
                take_items(pc, RED_MANDRAGORA_SAP, -1)
                take_items(pc, WHITE_MANDRAGORA_SAP, -1)
                take_items(pc, HONEY, -1)
                take_items(pc, GOLDEN_HONEY, -1)
                take_items(pc, DIONIAN_POTATO, -1)
                take_items(pc, GREEN_MOSS_BUNDLE, -1)
                take_items(pc, BROWN_MOSS_BUNDLE, -1)
                take_items(pc, MONSTER_EYE_MEAT, -1)
                give_items(pc, JONASS_2ND_STEAK_DISH, 1)
                html = "30469-05t2.html"
              end
            end

            if get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) == 2
              if Rnd.rand(10) < 5
                take_items(pc, INGREDIENT_LIST, -1)
                take_items(pc, RED_MANDRAGORA_SAP, -1)
                take_items(pc, WHITE_MANDRAGORA_SAP, -1)
                take_items(pc, HONEY, -1)
                take_items(pc, GOLDEN_HONEY, -1)
                take_items(pc, DIONIAN_POTATO, -1)
                take_items(pc, GREEN_MOSS_BUNDLE, -1)
                take_items(pc, BROWN_MOSS_BUNDLE, -1)
                take_items(pc, MONSTER_EYE_MEAT, -1)
                give_items(pc, JONASS_4TH_STEAK_DISH, 1)
                html = "30469-05t4.html"
              else
                take_items(pc, INGREDIENT_LIST, -1)
                take_items(pc, RED_MANDRAGORA_SAP, -1)
                take_items(pc, WHITE_MANDRAGORA_SAP, -1)
                take_items(pc, HONEY, -1)
                take_items(pc, GOLDEN_HONEY, -1)
                take_items(pc, DIONIAN_POTATO, -1)
                take_items(pc, GREEN_MOSS_BUNDLE, -1)
                take_items(pc, BROWN_MOSS_BUNDLE, -1)
                take_items(pc, MONSTER_EYE_MEAT, -1)
                give_items(pc, JONASS_3RD_STEAK_DISH, 1)
                html = "30469-05t3.html"
              end
            end

            if get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) == 3
              if Rnd.rand(10) < 5
                take_items(pc, INGREDIENT_LIST, -1)
                take_items(pc, RED_MANDRAGORA_SAP, -1)
                take_items(pc, WHITE_MANDRAGORA_SAP, -1)
                take_items(pc, HONEY, -1)
                take_items(pc, GOLDEN_HONEY, -1)
                take_items(pc, DIONIAN_POTATO, -1)
                take_items(pc, GREEN_MOSS_BUNDLE, -1)
                take_items(pc, BROWN_MOSS_BUNDLE, -1)
                take_items(pc, MONSTER_EYE_MEAT, -1)
                give_items(pc, JONASS_5TH_STEAK_DISH, 1)
                play_sound(pc, Sound::ITEMSOUND_QUEST_JACKPOT)
                html = "30469-05t5.html"
              else
                take_items(pc, INGREDIENT_LIST, -1)
                take_items(pc, RED_MANDRAGORA_SAP, -1)
                take_items(pc, WHITE_MANDRAGORA_SAP, -1)
                take_items(pc, HONEY, -1)
                take_items(pc, GOLDEN_HONEY, -1)
                take_items(pc, DIONIAN_POTATO, -1)
                take_items(pc, GREEN_MOSS_BUNDLE, -1)
                take_items(pc, BROWN_MOSS_BUNDLE, -1)
                take_items(pc, MONSTER_EYE_MEAT, -1)
                give_items(pc, JONASS_4TH_STEAK_DISH, 1)
                html = "30469-05t4.html"
              end
            end
          end
        else
          if get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) == 0
            if get_quest_items_count(pc, JONASS_1ST_STEAK_DISH) + get_quest_items_count(pc, JONASS_2ND_STEAK_DISH) + get_quest_items_count(pc, JONASS_3RD_STEAK_DISH) + get_quest_items_count(pc, JONASS_4TH_STEAK_DISH) + get_quest_items_count(pc, JONASS_5TH_STEAK_DISH) == 1
              if get_quest_items_count(pc, MIRIENS_REVIEW_1) + get_quest_items_count(pc, MIRIENS_REVIEW_2) + get_quest_items_count(pc, MIRIENS_REVIEW_3) + get_quest_items_count(pc, MIRIENS_REVIEW_4) + get_quest_items_count(pc, MIRIENS_REVIEW_5) == 0
                html = "30469-06.html"
              end
            else
              if get_quest_items_count(pc, MIRIENS_REVIEW_1) + get_quest_items_count(pc, MIRIENS_REVIEW_2) + get_quest_items_count(pc, MIRIENS_REVIEW_3) + get_quest_items_count(pc, MIRIENS_REVIEW_4) + get_quest_items_count(pc, MIRIENS_REVIEW_5) == 1
                if has_quest_items?(pc, MIRIENS_REVIEW_1)
                  take_items(pc, MIRIENS_REVIEW_1, 1)
                  give_adena(pc, 10000, true)
                  html = "30469-06t1.html"
                end

                if has_quest_items?(pc, MIRIENS_REVIEW_2)
                  take_items(pc, MIRIENS_REVIEW_2, 1)
                  give_adena(pc, 14870, true)
                  html = "30469-06t2.html"
                end

                if has_quest_items?(pc, MIRIENS_REVIEW_3)
                  take_items(pc, MIRIENS_REVIEW_3, 1)
                  give_adena(pc, 6490, true)
                  give_items(pc, JONASS_SALAD_RECIPE, 1)
                  html = "30469-06t3.html"
                end

                if has_quest_items?(pc, MIRIENS_REVIEW_4)
                  take_items(pc, MIRIENS_REVIEW_4, 1)
                  give_adena(pc, 12220, true)
                  give_items(pc, JONASS_SAUCE_RECIPE, 1)
                  html = "30469-06t4.html"
                end

                if has_quest_items?(pc, MIRIENS_REVIEW_5)
                  take_items(pc, MIRIENS_REVIEW_5, 1)
                  give_adena(pc, 16540, true)
                  give_items(pc, JONASS_STEAK_RECIPE, 1)
                  html = "30469-06t5.html"
                end

                qs.exit_quest(true, true)
              end
            end
          end
        end
      when ACCESSORY_MERCHANT_SONIA
        if has_quest_items?(pc, INGREDIENT_LIST) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5 && !has_at_least_one_quest_item?(pc, SONIAS_BOTANY_BOOK, RED_MANDRAGORA_SAP, WHITE_MANDRAGORA_SAP)
          give_items(pc, SONIAS_BOTANY_BOOK, 1)
          html = "30062-01.html"
        elsif has_quest_items?(pc, INGREDIENT_LIST, SONIAS_BOTANY_BOOK) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5 && !has_at_least_one_quest_item?(pc, RED_MANDRAGORA_SAP, WHITE_MANDRAGORA_SAP)
          if get_quest_items_count(pc, RED_MANDRAGORA_ROOT) + get_quest_items_count(pc, WHITE_MANDRAGORA_ROOT) < 40
            html = "30062-02.html"
          else
            if get_quest_items_count(pc, WHITE_MANDRAGORA_ROOT) < 40
              html = "30062-03.html"
            else
              take_items(pc, SONIAS_BOTANY_BOOK, 1)
              take_items(pc, RED_MANDRAGORA_ROOT, -1)
              take_items(pc, WHITE_MANDRAGORA_ROOT, -1)
              give_items(pc, WHITE_MANDRAGORA_SAP, 1)
              html = "30062-06.html"
            end
          end
        elsif has_quest_items?(pc, INGREDIENT_LIST) && !has_quest_items?(pc, SONIAS_BOTANY_BOOK) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5 && has_at_least_one_quest_item?(pc, RED_MANDRAGORA_SAP, WHITE_MANDRAGORA_SAP)
          html = "30062-07.html"
        end
      when PRIESTESS_GLYVKA
        if has_quest_items?(pc, INGREDIENT_LIST) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5 && !has_at_least_one_quest_item?(pc, GLYVKAS_BOTANY_BOOK, GREEN_MOSS_BUNDLE, BROWN_MOSS_BUNDLE)
          give_items(pc, GLYVKAS_BOTANY_BOOK, 1)
          html = "30067-01.html"
        elsif has_quest_items?(pc, INGREDIENT_LIST, GLYVKAS_BOTANY_BOOK) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5
          if get_quest_items_count(pc, GREEN_MARSH_MOSS) + get_quest_items_count(pc, BROWN_MARSH_MOSS) < 20
            html = "30067-02.html"
          else
            if get_quest_items_count(pc, BROWN_MARSH_MOSS) < 20
              html = "30067-03.html"
            else
              take_items(pc, GLYVKAS_BOTANY_BOOK, 1)
              take_items(pc, GREEN_MARSH_MOSS, -1)
              take_items(pc, BROWN_MARSH_MOSS, -1)
              give_items(pc, BROWN_MOSS_BUNDLE, 1)
              html = "30067-06.html"
            end
          end
        elsif has_quest_items?(pc, INGREDIENT_LIST) && !has_quest_items?(pc, GLYVKAS_BOTANY_BOOK) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5 && has_at_least_one_quest_item?(pc, GREEN_MOSS_BUNDLE, BROWN_MOSS_BUNDLE)
          html = "30067-07.html"
        end
      when MAGISTER_ROLLANT
        if has_quest_items?(pc, INGREDIENT_LIST) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5 && !has_at_least_one_quest_item?(pc, ROLLANTS_CREATURE_BOOK, MONSTER_EYE_MEAT)
          give_items(pc, ROLLANTS_CREATURE_BOOK, 1)
          html = "30069-01.html"
        elsif has_quest_items?(pc, INGREDIENT_LIST, ROLLANTS_CREATURE_BOOK) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5
          if get_quest_items_count(pc, BODY_OF_MONSTER_EYE) < 30
            html = "30069-02.html"
          else
            take_items(pc, ROLLANTS_CREATURE_BOOK, 1)
            take_items(pc, BODY_OF_MONSTER_EYE, -1)
            give_items(pc, MONSTER_EYE_MEAT, 1)
            html = "30069-03.html"
          end
        elsif has_quest_items?(pc, INGREDIENT_LIST, MONSTER_EYE_MEAT) && !has_quest_items?(pc, ROLLANTS_CREATURE_BOOK) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5
          html = "30069-04.html"
        end
      when GUARD_JACOB
        if has_quest_items?(pc, INGREDIENT_LIST) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5 && !has_at_least_one_quest_item?(pc, JACOBS_INSECT_BOOK, HONEY, GOLDEN_HONEY)
          give_items(pc, JACOBS_INSECT_BOOK, 1)
          html = "30073-01.html"
        elsif has_quest_items?(pc, INGREDIENT_LIST, JACOBS_INSECT_BOOK) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5
          if get_quest_items_count(pc, NECTAR) < 20
            html = "30073-02.html"
          else
            if get_quest_items_count(pc, ROYAL_JELLY) < 10
              html = "30073-03.html"
            else
              take_items(pc, JACOBS_INSECT_BOOK, 1)
              take_items(pc, NECTAR, -1)
              take_items(pc, ROYAL_JELLY, -1)
              give_items(pc, GOLDEN_HONEY, 1)
              html = "30073-06.html"
            end
          end
        elsif has_quest_items?(pc, INGREDIENT_LIST) && !has_quest_items?(pc, JACOBS_INSECT_BOOK) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5 && has_at_least_one_quest_item?(pc, HONEY, GOLDEN_HONEY)
          html = "30073-07.html"
        end
      when GROCER_PANO
        if has_quest_items?(pc, INGREDIENT_LIST) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5 && !has_at_least_one_quest_item?(pc, PANOS_CONTRACT, DIONIAN_POTATO)
          give_items(pc, PANOS_CONTRACT, 1)
          html = "30078-01.html"
        elsif has_quest_items?(pc, INGREDIENT_LIST, PANOS_CONTRACT) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5
          if get_quest_items_count(pc, HOBGOBLIN_AMULET) < 30
            html = "30078-02.html"
          else
            take_items(pc, PANOS_CONTRACT, 1)
            take_items(pc, HOBGOBLIN_AMULET, -1)
            give_items(pc, DIONIAN_POTATO, 1)
            html = "30078-03.html"
          end
        elsif has_quest_items?(pc, INGREDIENT_LIST, DIONIAN_POTATO) && !has_quest_items?(pc, PANOS_CONTRACT) && get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) < 5
          html = "30078-04.html"
        end
      when MAGISTER_MIRIEN
        if has_quest_items?(pc, INGREDIENT_LIST)
          html = "30461-01.html"
        else
          if get_quest_items_count(pc, RED_MANDRAGORA_SAP) + get_quest_items_count(pc, WHITE_MANDRAGORA_SAP) + get_quest_items_count(pc, HONEY) + get_quest_items_count(pc, GOLDEN_HONEY) + get_quest_items_count(pc, DIONIAN_POTATO) + get_quest_items_count(pc, GREEN_MOSS_BUNDLE) + get_quest_items_count(pc, BROWN_MOSS_BUNDLE) + get_quest_items_count(pc, MONSTER_EYE_MEAT) == 0
            if get_quest_items_count(pc, JONASS_1ST_STEAK_DISH) + get_quest_items_count(pc, JONASS_2ND_STEAK_DISH) + get_quest_items_count(pc, JONASS_3RD_STEAK_DISH) + get_quest_items_count(pc, JONASS_4TH_STEAK_DISH) + get_quest_items_count(pc, JONASS_5TH_STEAK_DISH) == 1
              if get_quest_items_count(pc, MIRIENS_REVIEW_1) + get_quest_items_count(pc, MIRIENS_REVIEW_2) + get_quest_items_count(pc, MIRIENS_REVIEW_3) + get_quest_items_count(pc, MIRIENS_REVIEW_4) + get_quest_items_count(pc, MIRIENS_REVIEW_5) == 0
                if has_quest_items?(pc, JONASS_1ST_STEAK_DISH)
                  take_items(pc, JONASS_1ST_STEAK_DISH, 1)
                  give_items(pc, MIRIENS_REVIEW_1, 1)
                  html = "30461-02t1.html"
                end

                if has_quest_items?(pc, JONASS_2ND_STEAK_DISH)
                  take_items(pc, JONASS_2ND_STEAK_DISH, 1)
                  give_items(pc, MIRIENS_REVIEW_2, 1)
                  html = "30461-02t2.html"
                end

                if has_quest_items?(pc, JONASS_3RD_STEAK_DISH)
                  take_items(pc, JONASS_3RD_STEAK_DISH, 1)
                  give_items(pc, MIRIENS_REVIEW_3, 1)
                  html = "30461-02t3.html"
                end

                if has_quest_items?(pc, JONASS_4TH_STEAK_DISH)
                  take_items(pc, JONASS_4TH_STEAK_DISH, 1)
                  give_items(pc, MIRIENS_REVIEW_4, 1)
                  html = "30461-02t4.html"
                end

                if has_quest_items?(pc, JONASS_5TH_STEAK_DISH)
                  take_items(pc, JONASS_5TH_STEAK_DISH, 1)
                  give_items(pc, MIRIENS_REVIEW_5, 1)
                  html = "30461-02t5.html"
                end
              end
            else
              if get_quest_items_count(pc, MIRIENS_REVIEW_1) + get_quest_items_count(pc, MIRIENS_REVIEW_2) + get_quest_items_count(pc, MIRIENS_REVIEW_3) + get_quest_items_count(pc, MIRIENS_REVIEW_4) + get_quest_items_count(pc, MIRIENS_REVIEW_5) == 1
                html = "30461-04.html"
              end
            end
          end
        end
      else
        # [automatically added else]
      end

    end

    html || get_no_quest_msg(pc)
  end
end
