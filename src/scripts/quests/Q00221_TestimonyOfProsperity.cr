class Scripts::Q00221_TestimonyOfProsperity < Quest
  # NPCs
  private WAREHOUSE_KEEPER_WILFORD = 30005
  private WAREHOUSE_KEEPER_PARMAN = 30104
  private LILITH = 30368
  private GUARD_BRIGHT = 30466
  private TRADER_SHARI = 30517
  private TRADER_MION = 30519
  private IRON_GATES_LOCKIRIN = 30531
  private GOLDEN_WHEELS_SPIRON = 30532
  private SILVER_SCALES_BALANKI = 30533
  private BRONZE_KEYS_KEEF = 30534
  private GRAY_PILLAR_MEMBER_FILAUR = 30535
  private BLACK_ANVILS_ARIN = 30536
  private MARYSE_REDBONNET = 30553
  private MINER_BOLTER = 30554
  private CARRIER_TOROCCO = 30555
  private MASTER_TOMA = 30556
  private PIOTUR = 30597
  private EMILY = 30620
  private MAESTRO_NIKOLA = 30621
  private BOX_OF_TITAN = 30622
  # Items
  private ADENA = 57
  private ANIMAL_SKIN = 1867
  private RECIPE_TITAN_KEY = 3023
  private KEY_OF_TITAN = 3030
  private RING_OF_TESTIMONY_1ST = 3239
  private RING_OF_TESTIMONY_2ND = 3240
  private OLD_ACCOUNT_BOOK = 3241
  private BLESSED_SEED = 3242
  private EMILYS_RECIPE = 3243
  private LILITHS_ELVEN_WAFER = 3244
  private MAPHR_TABLET_FRAGMENT = 3245
  private COLLECTION_LICENSE = 3246
  private LOCKIRINS_1ST_NOTICE = 3247
  private LOCKIRINS_2ND_NOTICE = 3248
  private LOCKIRINS_3RD_NOTICE = 3249
  private LOCKIRINS_4TH_NOTICE = 3250
  private LOCKIRINS_5TH_NOTICE = 3251
  private CONTRIBUTION_OF_SHARI = 3252
  private CONTRIBUTION_OF_MION = 3253
  private CONTRIBUTION_OF_MARYSE = 3254
  private MARYSES_REQUEST = 3255
  private CONTRIBUTION_OF_TOMA = 3256
  private RECEIPT_OF_BOLTER = 3257
  private RECEIPT_OF_CONTRIBUTION_1ST = 3258
  private RECEIPT_OF_CONTRIBUTION_2ND = 3259
  private RECEIPT_OF_CONTRIBUTION_3RD = 3260
  private RECEIPT_OF_CONTRIBUTION_4TH = 3261
  private RECEIPT_OF_CONTRIBUTION_5TH = 3262
  private PROCURATION_OF_TOROCCO = 3263
  private BRIGHTS_LIST = 3264
  private MANDRAGORA_PETAL = 3265
  private CRIMSON_MOSS = 3266
  private MANDRAGORA_BOUGUET = 3267
  private PARMANS_INSTRUCTIONS = 3268
  private PARMANS_LETTER = 3269
  private CLAY_DOUGH = 3270
  private PATTERN_OF_KEYHOLE = 3271
  private NIKOLAS_LIST = 3272
  private STAKATO_SHELL = 3273
  private TOAD_LORD_SAC = 3274
  private MARSH_SPIDER_THORN = 3275
  private CRYSTAL_BROOCH = 3428
  # Reward
  private MARK_OF_PROSPERITY = 3238
  private DIMENSIONAL_DIAMOND = 7562
  # Monster
  private MANDRAGORA_SPROUT1 = 20154
  private MANDRAGORA_SAPLING = 20155
  private MANDRAGORA_BLOSSOM = 20156
  private MARSH_STAKATO = 20157
  private MANDRAGORA_SPROUT2 = 20223
  private GIANT_CRIMSON_ANT = 20228
  private MARSH_STAKATO_WORKER = 20230
  private TOAD_LORD = 20231
  private MARSH_STAKATO_SOLDIER = 20232
  private MARSH_SPIDER = 20233
  private MARSH_STAKATO_DRONE = 20234
  # Misc
  private MIN_LEVEL = 37

  def initialize
    super(221, self.class.simple_name, "Testimony Of Prosperity")

    add_start_npc(WAREHOUSE_KEEPER_PARMAN)
    add_talk_id(
      WAREHOUSE_KEEPER_PARMAN, WAREHOUSE_KEEPER_WILFORD, LILITH, GUARD_BRIGHT,
      TRADER_SHARI, TRADER_MION, IRON_GATES_LOCKIRIN, GOLDEN_WHEELS_SPIRON,
      SILVER_SCALES_BALANKI, BRONZE_KEYS_KEEF, GRAY_PILLAR_MEMBER_FILAUR,
      BLACK_ANVILS_ARIN, MARYSE_REDBONNET, MINER_BOLTER, CARRIER_TOROCCO,
      MASTER_TOMA, PIOTUR, EMILY, MAESTRO_NIKOLA, BOX_OF_TITAN
    )
    add_kill_id(
      MANDRAGORA_SPROUT1, MANDRAGORA_SAPLING, MANDRAGORA_BLOSSOM, MARSH_STAKATO,
      MANDRAGORA_SPROUT2, GIANT_CRIMSON_ANT, MARSH_STAKATO_WORKER, TOAD_LORD,
      MARSH_STAKATO_SOLDIER, MARSH_SPIDER, MARSH_STAKATO_DRONE
    )
    register_quest_items(
      RECIPE_TITAN_KEY, KEY_OF_TITAN, RING_OF_TESTIMONY_1ST,
      RING_OF_TESTIMONY_2ND, OLD_ACCOUNT_BOOK, BLESSED_SEED, EMILYS_RECIPE,
      LILITHS_ELVEN_WAFER, MAPHR_TABLET_FRAGMENT, COLLECTION_LICENSE,
      LOCKIRINS_1ST_NOTICE, LOCKIRINS_2ND_NOTICE, LOCKIRINS_3RD_NOTICE,
      LOCKIRINS_4TH_NOTICE, LOCKIRINS_5TH_NOTICE, CONTRIBUTION_OF_SHARI,
      CONTRIBUTION_OF_MION, CONTRIBUTION_OF_MARYSE, MARYSES_REQUEST,
      CONTRIBUTION_OF_TOMA, RECEIPT_OF_BOLTER, RECEIPT_OF_CONTRIBUTION_1ST,
      RECEIPT_OF_CONTRIBUTION_2ND, RECEIPT_OF_CONTRIBUTION_3RD,
      RECEIPT_OF_CONTRIBUTION_4TH, RECEIPT_OF_CONTRIBUTION_5TH,
      PROCURATION_OF_TOROCCO, BRIGHTS_LIST, MANDRAGORA_PETAL, CRIMSON_MOSS,
      MANDRAGORA_BOUGUET, PARMANS_INSTRUCTIONS, PARMANS_LETTER, CLAY_DOUGH,
      PATTERN_OF_KEYHOLE, NIKOLAS_LIST, STAKATO_SHELL, TOAD_LORD_SAC,
      MARSH_SPIDER_THORN, CRYSTAL_BROOCH
    )
  end

  def on_adv_event(event, npc, pc)
    return unless pc
    return unless qs = get_quest_state(pc, false)

    case event
    when "ACCEPT"
      if qs.created?
        qs.start_quest
        unless has_quest_items?(pc, RING_OF_TESTIMONY_1ST)
          give_items(pc, RING_OF_TESTIMONY_1ST, 1)
        end
        play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
        if pc.variables.get_i32("2ND_CLASS_DIAMOND_REWARD", 0) == 0
          give_items(pc, DIMENSIONAL_DIAMOND, 50)
          pc.variables["2ND_CLASS_DIAMOND_REWARD"] = 1
          html = "30104-04e.htm"
        else
          html = "30104-04.htm"
        end
      end
    when "30104-08.html"
      take_items(pc, RING_OF_TESTIMONY_1ST, 1)
      give_items(pc, RING_OF_TESTIMONY_2ND, 1)
      take_items(pc, OLD_ACCOUNT_BOOK, 1)
      take_items(pc, BLESSED_SEED, 1)
      take_items(pc, EMILYS_RECIPE, 1)
      take_items(pc, LILITHS_ELVEN_WAFER, 1)
      give_items(pc, PARMANS_LETTER, 1)
      qs.set_cond(4, true)
      html = event
    when "30104-04a.html", "30104-04b.html", "30104-04c.html", "30104-04d.html",
         "30104-05.html", "30104-08a.html", "30104-08b.html", "30104-08c.html",
         "30005-02.html", "30005-03.html", "30368-02.html", "30466-02.html",
         "30531-02.html", "30620-02.html", "30621-02.html", "30621-03.html"
      html = event
    when "30005-04.html"
      give_items(pc, CRYSTAL_BROOCH, 1)
      html = event
    when "30368-03.html"
      if has_quest_items?(pc, CRYSTAL_BROOCH)
        give_items(pc, LILITHS_ELVEN_WAFER, 1)
        take_items(pc, CRYSTAL_BROOCH, 1)
        if has_quest_items?(pc, OLD_ACCOUNT_BOOK, BLESSED_SEED, EMILYS_RECIPE)
          qs.set_cond(2, true)
        end
        html = event
      end
    when "30466-03.html"
      give_items(pc, BRIGHTS_LIST, 1)
      html = event
    when "30531-03.html"
      give_items(pc, COLLECTION_LICENSE, 1)
      give_items(pc, LOCKIRINS_1ST_NOTICE, 1)
      give_items(pc, LOCKIRINS_2ND_NOTICE, 1)
      give_items(pc, LOCKIRINS_3RD_NOTICE, 1)
      give_items(pc, LOCKIRINS_4TH_NOTICE, 1)
      give_items(pc, LOCKIRINS_5TH_NOTICE, 1)
      html = event
    when "30534-03a.html"
      if get_quest_items_count(pc, ADENA) < 5000
        html = event
      elsif has_quest_items?(pc, PROCURATION_OF_TOROCCO)
        take_items(pc, ADENA, 5000)
        give_items(pc, RECEIPT_OF_CONTRIBUTION_3RD, 1)
        take_items(pc, PROCURATION_OF_TOROCCO, 1)
        html = "30534-03b.html"
      end
    when "30555-02.html"
      give_items(pc, PROCURATION_OF_TOROCCO, 1)
      html = event
    when "30597-02.html"
      give_items(pc, BLESSED_SEED, 1)
      if has_quest_items?(pc, OLD_ACCOUNT_BOOK, EMILYS_RECIPE, LILITHS_ELVEN_WAFER)
        qs.set_cond(2, true)
      end
      html = event
    when "30620-03.html"
      if has_quest_items?(pc, MANDRAGORA_BOUGUET)
        give_items(pc, EMILYS_RECIPE, 1)
        take_items(pc, MANDRAGORA_BOUGUET, 1)
        if has_quest_items?(pc, OLD_ACCOUNT_BOOK, BLESSED_SEED, LILITHS_ELVEN_WAFER)
          qs.set_cond(2, true)
        end
        html = event
      end
    when "30621-04.html"
      give_items(pc, CLAY_DOUGH, 1)
      qs.set_cond(5, true)
      html = event
    when "30622-02.html"
      if has_quest_items?(pc, CLAY_DOUGH)
        take_items(pc, CLAY_DOUGH, 1)
        give_items(pc, PATTERN_OF_KEYHOLE, 1)
        qs.set_cond(6, true)
        html = event
      end
    when "30622-04.html"
      if has_quest_items?(pc, KEY_OF_TITAN)
        take_items(pc, KEY_OF_TITAN, 1)
        give_items(pc, MAPHR_TABLET_FRAGMENT, 1)
        take_items(pc, NIKOLAS_LIST, 1)
        take_items(pc, RECIPE_TITAN_KEY, 1)
        take_items(pc, STAKATO_SHELL, -1)
        take_items(pc, TOAD_LORD_SAC, -1)
        take_items(pc, MARSH_SPIDER_THORN, -1)
        qs.set_cond(9, true)
        html = event
      end
    end

    html
  end

  def on_kill(npc, killer, is_summon)
    qs = get_quest_state(killer, false)
    if qs && qs.started? && Util.in_range?(1500, npc, killer, true)
      case npc.id
      when MANDRAGORA_SPROUT1, MANDRAGORA_SAPLING, MANDRAGORA_BLOSSOM, MANDRAGORA_SPROUT2
        if has_quest_items?(killer, RING_OF_TESTIMONY_1ST, BRIGHTS_LIST) && !has_quest_items?(killer, EMILYS_RECIPE)
          if get_quest_items_count(killer, MANDRAGORA_PETAL) < 20
            give_items(killer, MANDRAGORA_PETAL, 1)
            if get_quest_items_count(killer, MANDRAGORA_PETAL) == 20
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when MARSH_STAKATO, MARSH_STAKATO_WORKER, MARSH_STAKATO_SOLDIER, MARSH_STAKATO_DRONE
        if has_quest_items?(killer, RING_OF_TESTIMONY_2ND, NIKOLAS_LIST) && !has_at_least_one_quest_item?(killer, CLAY_DOUGH, PATTERN_OF_KEYHOLE)
          if get_quest_items_count(killer, STAKATO_SHELL) < 20
            give_items(killer, STAKATO_SHELL, 1)
            if get_quest_items_count(killer, STAKATO_SHELL) == 20
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              if get_quest_items_count(killer, TOAD_LORD_SAC) >= 10 && get_quest_items_count(killer, MARSH_SPIDER_THORN) >= 10
                qs.set_cond(8)
              end
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when GIANT_CRIMSON_ANT
        if has_quest_items?(killer, RING_OF_TESTIMONY_1ST, BRIGHTS_LIST) && !has_quest_items?(killer, EMILYS_RECIPE)
          if get_quest_items_count(killer, CRIMSON_MOSS) < 10
            give_items(killer, CRIMSON_MOSS, 1)
            if get_quest_items_count(killer, CRIMSON_MOSS) == 10
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when TOAD_LORD
        if has_quest_items?(killer, RING_OF_TESTIMONY_2ND, NIKOLAS_LIST) && !has_at_least_one_quest_item?(killer, CLAY_DOUGH, PATTERN_OF_KEYHOLE)
          if get_quest_items_count(killer, TOAD_LORD_SAC) < 10
            give_items(killer, TOAD_LORD_SAC, 1)
            if get_quest_items_count(killer, TOAD_LORD_SAC) == 10
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              if get_quest_items_count(killer, STAKATO_SHELL) >= 20 && get_quest_items_count(killer, MARSH_SPIDER_THORN) >= 10
                qs.set_cond(8)
              end
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      when MARSH_SPIDER
        if has_quest_items?(killer, RING_OF_TESTIMONY_2ND, NIKOLAS_LIST) && !has_at_least_one_quest_item?(killer, CLAY_DOUGH, PATTERN_OF_KEYHOLE)
          if get_quest_items_count(killer, MARSH_SPIDER_THORN) < 10
            give_items(killer, MARSH_SPIDER_THORN, 1)
            if get_quest_items_count(killer, MARSH_SPIDER_THORN) == 10
              play_sound(killer, Sound::ITEMSOUND_QUEST_MIDDLE)
              if get_quest_items_count(killer, STAKATO_SHELL) >= 20 && get_quest_items_count(killer, TOAD_LORD_SAC) >= 10
                qs.set_cond(8)
              end
            else
              play_sound(killer, Sound::ITEMSOUND_QUEST_ITEMGET)
            end
          end
        end
      end
    end

    super
  end

  def on_talk(npc, pc)
    qs = get_quest_state!(pc)

    if qs.created?
      if npc.id == WAREHOUSE_KEEPER_PARMAN
        if pc.race.dwarf? && pc.level >= MIN_LEVEL && pc.in_category?(CategoryType::DWARF_2ND_GROUP)
          html = "30104-03.htm"
        elsif pc.race.dwarf? && pc.level >= MIN_LEVEL
          html = "30104-01a.html"
        elsif pc.race.dwarf?
          html = "30104-02.html"
        else
          html = "30104-01.html"
        end
      end
    elsif qs.started?
      case npc.id
      when WAREHOUSE_KEEPER_PARMAN
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST)
          if has_quest_items?(pc, OLD_ACCOUNT_BOOK, BLESSED_SEED, EMILYS_RECIPE, LILITHS_ELVEN_WAFER)
            html = "30104-06.html"
          else
            html = "30104-05.html"
          end
        elsif has_quest_items?(pc, PARMANS_INSTRUCTIONS)
          take_items(pc, PARMANS_INSTRUCTIONS, 1)
          give_items(pc, RING_OF_TESTIMONY_2ND, 1)
          give_items(pc, PARMANS_LETTER, 1)
          qs.set_cond(4, true)
          html = "30104-10.html"
        elsif has_quest_items?(pc, RING_OF_TESTIMONY_2ND)
          if has_quest_items?(pc, PARMANS_LETTER)
            html = "30104-11.html"
          elsif has_at_least_one_quest_item?(pc, CLAY_DOUGH, PATTERN_OF_KEYHOLE, NIKOLAS_LIST)
            html = "30104-12.html"
          elsif has_quest_items?(pc, MAPHR_TABLET_FRAGMENT)
            give_adena(pc, 217682, true)
            give_items(pc, MARK_OF_PROSPERITY, 1)
            add_exp_and_sp(pc, 1199958, 80080)
            qs.exit_quest(false, true)
            pc.send_packet(SocialAction.new(pc.l2id, 3))
            html = "30104-13.html"
          end
        end
      when WAREHOUSE_KEEPER_WILFORD
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST)
          if !has_at_least_one_quest_item?(pc, LILITHS_ELVEN_WAFER, CRYSTAL_BROOCH)
            html = "30005-01.html"
          elsif has_quest_items?(pc, CRYSTAL_BROOCH) && !has_quest_items?(pc, LILITHS_ELVEN_WAFER)
            html = "30005-05.html"
          elsif has_quest_items?(pc, LILITHS_ELVEN_WAFER)
            html = "30005-06.html"
          end
        elsif has_quest_items?(pc, RING_OF_TESTIMONY_2ND)
          html = "30005-07.html"
        end
      when LILITH
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST)
          if has_quest_items?(pc, CRYSTAL_BROOCH) && !has_quest_items?(pc, LILITHS_ELVEN_WAFER)
            html = "30368-01.html"
          else
            html = "30368-04.html"
          end
        elsif has_quest_items?(pc, RING_OF_TESTIMONY_2ND)
          html = "30368-05.html"
        end
      when GUARD_BRIGHT
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST)
          if !has_at_least_one_quest_item?(pc, EMILYS_RECIPE, BRIGHTS_LIST, MANDRAGORA_BOUGUET)
            html = "30466-01.html"
          elsif has_quest_items?(pc, BRIGHTS_LIST) && !has_quest_items?(pc, EMILYS_RECIPE)
            if get_quest_items_count(pc, MANDRAGORA_PETAL) < 20 || get_quest_items_count(pc, CRIMSON_MOSS) < 10
              html = "30466-04.html"
            else
              take_items(pc, BRIGHTS_LIST, 1)
              take_items(pc, MANDRAGORA_PETAL, -1)
              take_items(pc, CRIMSON_MOSS, -1)
              give_items(pc, MANDRAGORA_BOUGUET, 1)
              html = "30466-05.html"
            end
          elsif has_quest_items?(pc, MANDRAGORA_BOUGUET) && !has_at_least_one_quest_item?(pc, EMILYS_RECIPE, BRIGHTS_LIST)
            html = "30466-06.html"
          elsif has_quest_items?(pc, EMILYS_RECIPE)
            html = "30466-07.html"
          end
        elsif has_quest_items?(pc, RING_OF_TESTIMONY_2ND)
          html = "30466-08.html"
        end
      when TRADER_SHARI
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST, COLLECTION_LICENSE)
          if !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_1ST, CONTRIBUTION_OF_SHARI, LOCKIRINS_1ST_NOTICE)
            give_items(pc, CONTRIBUTION_OF_SHARI, 1)
            html = "30517-01.html"
          elsif has_quest_items?(pc, CONTRIBUTION_OF_SHARI) && !has_at_least_one_quest_item?(pc, LOCKIRINS_1ST_NOTICE, RECEIPT_OF_CONTRIBUTION_1ST)
            html = "30517-02.html"
          end
        end
      when TRADER_MION
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST, COLLECTION_LICENSE)
          if !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_2ND, CONTRIBUTION_OF_MION, LOCKIRINS_2ND_NOTICE)
            give_items(pc, CONTRIBUTION_OF_MION, 1)
            html = "30519-01.html"
          elsif has_quest_items?(pc, CONTRIBUTION_OF_MION) && !has_at_least_one_quest_item?(pc, LOCKIRINS_2ND_NOTICE, RECEIPT_OF_CONTRIBUTION_2ND)
            html = "30519-02.html"
          end
        end
      when IRON_GATES_LOCKIRIN
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST)
          if !has_at_least_one_quest_item?(pc, COLLECTION_LICENSE, OLD_ACCOUNT_BOOK)
            html = "30531-01.html"
          elsif has_quest_items?(pc, COLLECTION_LICENSE)
            if has_quest_items?(pc, RECEIPT_OF_CONTRIBUTION_1ST, RECEIPT_OF_CONTRIBUTION_2ND, RECEIPT_OF_CONTRIBUTION_3RD, RECEIPT_OF_CONTRIBUTION_4TH, RECEIPT_OF_CONTRIBUTION_5TH)
              give_items(pc, OLD_ACCOUNT_BOOK, 1)
              take_items(pc, COLLECTION_LICENSE, 1)
              take_items(pc, RECEIPT_OF_CONTRIBUTION_1ST, 1)
              take_items(pc, RECEIPT_OF_CONTRIBUTION_2ND, 1)
              take_items(pc, RECEIPT_OF_CONTRIBUTION_3RD, 1)
              take_items(pc, RECEIPT_OF_CONTRIBUTION_4TH, 1)
              take_items(pc, RECEIPT_OF_CONTRIBUTION_5TH, 1)
              play_sound(pc, Sound::ITEMSOUND_QUEST_MIDDLE)
              if has_quest_items?(pc, BLESSED_SEED, EMILYS_RECIPE, LILITHS_ELVEN_WAFER)
                qs.set_cond(2, true)
              end
              html = "30531-05.html"
            else
              html = "30531-04.html"
            end
          elsif has_quest_items?(pc, OLD_ACCOUNT_BOOK) && !has_quest_items?(pc, COLLECTION_LICENSE)
            html = "30531-06.html"
          end
        elsif has_quest_items?(pc, RING_OF_TESTIMONY_2ND)
          html = "30531-07.html"
        end
      when GOLDEN_WHEELS_SPIRON
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST, COLLECTION_LICENSE)
          if has_quest_items?(pc, LOCKIRINS_1ST_NOTICE) && !has_at_least_one_quest_item?(pc, CONTRIBUTION_OF_SHARI, RECEIPT_OF_CONTRIBUTION_1ST)
            take_items(pc, LOCKIRINS_1ST_NOTICE, 1)
            html = "30532-01.html"
          elsif !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_1ST, CONTRIBUTION_OF_SHARI, LOCKIRINS_1ST_NOTICE)
            html = "30532-02.html"
          elsif has_quest_items?(pc, CONTRIBUTION_OF_SHARI) && !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_1ST, LOCKIRINS_1ST_NOTICE)
            take_items(pc, CONTRIBUTION_OF_SHARI, 1)
            give_items(pc, RECEIPT_OF_CONTRIBUTION_1ST, 1)
            html = "30532-03.html"
          elsif has_quest_items?(pc, RECEIPT_OF_CONTRIBUTION_1ST) && !has_at_least_one_quest_item?(pc, CONTRIBUTION_OF_SHARI, LOCKIRINS_1ST_NOTICE)
            html = "30532-04.html"
          end
        end
      when SILVER_SCALES_BALANKI
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST, COLLECTION_LICENSE)
          if has_quest_items?(pc, LOCKIRINS_2ND_NOTICE) && !has_quest_items?(pc, RECEIPT_OF_CONTRIBUTION_2ND) && get_quest_items_count(pc, CONTRIBUTION_OF_MION) + get_quest_items_count(pc, CONTRIBUTION_OF_MARYSE) < 2
            take_items(pc, LOCKIRINS_2ND_NOTICE, 1)
            html = "30533-01.html"
          elsif !has_at_least_one_quest_item?(pc, LOCKIRINS_2ND_NOTICE, RECEIPT_OF_CONTRIBUTION_2ND) && get_quest_items_count(pc, CONTRIBUTION_OF_MION) + get_quest_items_count(pc, CONTRIBUTION_OF_MARYSE) < 2
            html = "30533-02.html"
          elsif !has_at_least_one_quest_item?(pc, LOCKIRINS_2ND_NOTICE, RECEIPT_OF_CONTRIBUTION_2ND) && has_quest_items?(pc, CONTRIBUTION_OF_MION, CONTRIBUTION_OF_MARYSE)
            take_items(pc, CONTRIBUTION_OF_MION, 1)
            take_items(pc, CONTRIBUTION_OF_MARYSE, 1)
            give_items(pc, RECEIPT_OF_CONTRIBUTION_2ND, 1)
            html = "30533-03.html"
          elsif !has_quest_items?(pc, LOCKIRINS_2ND_NOTICE) && has_quest_items?(pc, RECEIPT_OF_CONTRIBUTION_2ND) && !has_quest_items?(pc, CONTRIBUTION_OF_MION, CONTRIBUTION_OF_MARYSE)
            html = "30533-04.html"
          end
        end
      when BRONZE_KEYS_KEEF
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST, COLLECTION_LICENSE)
          if has_quest_items?(pc, LOCKIRINS_3RD_NOTICE) && !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_3RD, PROCURATION_OF_TOROCCO)
            take_items(pc, LOCKIRINS_3RD_NOTICE, 1)
            html = "30534-01.html"
          elsif !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_3RD, PROCURATION_OF_TOROCCO, LOCKIRINS_3RD_NOTICE)
            html = "30534-02.html"
          elsif has_quest_items?(pc, PROCURATION_OF_TOROCCO) && !has_at_least_one_quest_item?(pc, LOCKIRINS_3RD_NOTICE, RECEIPT_OF_CONTRIBUTION_3RD)
            html = "30534-03.html"
          elsif has_quest_items?(pc, RECEIPT_OF_CONTRIBUTION_3RD) && !has_at_least_one_quest_item?(pc, PROCURATION_OF_TOROCCO, LOCKIRINS_3RD_NOTICE)
            html = "30534-04.html"
          end
        end
      when GRAY_PILLAR_MEMBER_FILAUR
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST, COLLECTION_LICENSE)
          if has_quest_items?(pc, LOCKIRINS_4TH_NOTICE) && !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_4TH, RECEIPT_OF_BOLTER)
            take_items(pc, LOCKIRINS_4TH_NOTICE, 1)
            html = "30535-01.html"
          elsif !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_4TH, RECEIPT_OF_BOLTER, LOCKIRINS_4TH_NOTICE)
            html = "30535-02.html"
          elsif has_quest_items?(pc, RECEIPT_OF_BOLTER) && !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_4TH, LOCKIRINS_4TH_NOTICE)
            take_items(pc, RECEIPT_OF_BOLTER, 1)
            give_items(pc, RECEIPT_OF_CONTRIBUTION_4TH, 1)
            html = "30535-03.html"
          elsif has_quest_items?(pc, RECEIPT_OF_CONTRIBUTION_4TH) && !has_at_least_one_quest_item?(pc, RECEIPT_OF_BOLTER, LOCKIRINS_4TH_NOTICE)
            html = "30535-04.html"
          end
        end
      when BLACK_ANVILS_ARIN
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST, COLLECTION_LICENSE)
          if has_quest_items?(pc, LOCKIRINS_5TH_NOTICE) && !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_5TH, CONTRIBUTION_OF_TOMA)
            take_items(pc, LOCKIRINS_5TH_NOTICE, 1)
            html = "30536-01.html"
          elsif !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_5TH, CONTRIBUTION_OF_TOMA, LOCKIRINS_5TH_NOTICE)
            html = "30536-02.html"
          elsif has_quest_items?(pc, CONTRIBUTION_OF_TOMA) && !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_5TH, LOCKIRINS_5TH_NOTICE)
            take_items(pc, CONTRIBUTION_OF_TOMA, 1)
            give_items(pc, RECEIPT_OF_CONTRIBUTION_5TH, 1)
            html = "30536-03.html"
          elsif has_quest_items?(pc, RECEIPT_OF_CONTRIBUTION_5TH) && !has_at_least_one_quest_item?(pc, CONTRIBUTION_OF_TOMA, LOCKIRINS_5TH_NOTICE)
            html = "30536-04.html"
          end
        end
      when MARYSE_REDBONNET
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST, COLLECTION_LICENSE)
          if !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_2ND, CONTRIBUTION_OF_MARYSE, LOCKIRINS_2ND_NOTICE, MARYSES_REQUEST)
            give_items(pc, MARYSES_REQUEST, 1)
            html = "30553-01.html"
          elsif has_quest_items?(pc, MARYSES_REQUEST) && !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_2ND, CONTRIBUTION_OF_MARYSE, LOCKIRINS_2ND_NOTICE)
            if get_quest_items_count(pc, ANIMAL_SKIN) < 10
              html = "30553-02.html"
            else
              take_items(pc, ANIMAL_SKIN, 10)
              give_items(pc, CONTRIBUTION_OF_MARYSE, 1)
              take_items(pc, MARYSES_REQUEST, 1)
              html = "30553-03.html"
            end
          elsif has_quest_items?(pc, CONTRIBUTION_OF_MARYSE) && !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_2ND, LOCKIRINS_2ND_NOTICE, MARYSES_REQUEST)
            html = "30553-04.html"
          end
        end
      when MINER_BOLTER
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST, COLLECTION_LICENSE)
          if !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_4TH, RECEIPT_OF_BOLTER, LOCKIRINS_4TH_NOTICE)
            give_items(pc, RECEIPT_OF_BOLTER, 1)
            html = "30554-01.html"
          elsif has_quest_items?(pc, RECEIPT_OF_BOLTER) && !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_4TH, LOCKIRINS_4TH_NOTICE)
            html = "30554-02.html"
          end
        end
      when CARRIER_TOROCCO
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST, COLLECTION_LICENSE)
          if !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_3RD, PROCURATION_OF_TOROCCO, LOCKIRINS_3RD_NOTICE)
            html = "30555-01.html"
          elsif has_quest_items?(pc, PROCURATION_OF_TOROCCO) && !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_3RD, LOCKIRINS_3RD_NOTICE)
            html = "30555-03.html"
          end
        end
      when MASTER_TOMA
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST, COLLECTION_LICENSE)
          if !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_5TH, CONTRIBUTION_OF_TOMA, LOCKIRINS_5TH_NOTICE)
            give_items(pc, CONTRIBUTION_OF_TOMA, 1)
            html = "30556-01.html"
          elsif has_quest_items?(pc, CONTRIBUTION_OF_TOMA) && !has_at_least_one_quest_item?(pc, RECEIPT_OF_CONTRIBUTION_5TH, LOCKIRINS_5TH_NOTICE)
            html = "30556-02.html"
          end
        end
      when PIOTUR
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST)
          if !has_quest_items?(pc, BLESSED_SEED)
            html = "30597-01.html"
          else
            html = "30597-03.html"
          end
        elsif has_quest_items?(pc, RING_OF_TESTIMONY_2ND)
          html = "30597-04.html"
        end
      when EMILY
        if has_quest_items?(pc, RING_OF_TESTIMONY_1ST)
          if has_quest_items?(pc, MANDRAGORA_BOUGUET) && !has_at_least_one_quest_item?(pc, EMILYS_RECIPE, BRIGHTS_LIST)
            html = "30620-01.html"
          elsif has_quest_items?(pc, EMILYS_RECIPE)
            html = "30620-04.html"
          end
        elsif has_quest_items?(pc, RING_OF_TESTIMONY_2ND)
          html = "30620-05.html"
        end
      when MAESTRO_NIKOLA
        if has_quest_items?(pc, RING_OF_TESTIMONY_2ND)
          if !has_at_least_one_quest_item?(pc, CLAY_DOUGH, PATTERN_OF_KEYHOLE, NIKOLAS_LIST, MAPHR_TABLET_FRAGMENT)
            take_items(pc, PARMANS_LETTER, 1)
            html = "30621-01.html"
          elsif has_quest_items?(pc, CLAY_DOUGH) && !has_at_least_one_quest_item?(pc, PATTERN_OF_KEYHOLE, NIKOLAS_LIST, MAPHR_TABLET_FRAGMENT)
            html = "30621-05.html"
          elsif has_quest_items?(pc, PATTERN_OF_KEYHOLE) && !has_at_least_one_quest_item?(pc, CLAY_DOUGH, NIKOLAS_LIST, MAPHR_TABLET_FRAGMENT)
            give_items(pc, RECIPE_TITAN_KEY, 1)
            take_items(pc, PATTERN_OF_KEYHOLE, 1)
            give_items(pc, NIKOLAS_LIST, 1)
            qs.set_cond(7, true)
            html = "30621-06.html"
          elsif has_quest_items?(pc, NIKOLAS_LIST) && !has_at_least_one_quest_item?(pc, CLAY_DOUGH, PATTERN_OF_KEYHOLE, MAPHR_TABLET_FRAGMENT, KEY_OF_TITAN)
            html = "30621-07.html"
          elsif has_quest_items?(pc, NIKOLAS_LIST, KEY_OF_TITAN) && !has_at_least_one_quest_item?(pc, CLAY_DOUGH, PATTERN_OF_KEYHOLE, MAPHR_TABLET_FRAGMENT)
            html = "30621-08.html"
          elsif has_quest_items?(pc, MAPHR_TABLET_FRAGMENT) && !has_at_least_one_quest_item?(pc, CLAY_DOUGH, PATTERN_OF_KEYHOLE, NIKOLAS_LIST)
            html = "30621-09.html"
          end
        end
      when BOX_OF_TITAN
        if has_quest_items?(pc, RING_OF_TESTIMONY_2ND)
          if has_quest_items?(pc, CLAY_DOUGH) && !has_quest_items?(pc, PATTERN_OF_KEYHOLE)
            html = "30622-01.html"
          elsif has_quest_items?(pc, KEY_OF_TITAN) && !has_quest_items?(pc, MAPHR_TABLET_FRAGMENT)
            html = "30622-03.html"
          elsif !has_at_least_one_quest_item?(pc, KEY_OF_TITAN, CLAY_DOUGH)
            html = "30622-05.html"
          end
        end
      end
    elsif qs.completed?
      if npc.id == WAREHOUSE_KEEPER_PARMAN
        html = get_already_completed_msg(pc)
      end
    end

    html || get_no_quest_msg(pc)
  end
end
